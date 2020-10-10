from json.decoder import JSONDecodeError

from django.contrib.auth import get_user_model
from django.db import IntegrityError

from django.http import JsonResponse
import json

from rest_framework.exceptions import APIException, ValidationError
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework import viewsets
from .models import Layer, ConvLayer, DenseLayer, NeuralModel, Model, ModelType, Data, Device
from .serializers import LayerSerializer, ConvLayerSerializer, DenseLayerSerializer, UserSerializer, \
    NeuralModelSerializer, ModelSerializer, DataSerializer, ModelTrainSerializer, DeviceSerializer, \
    LinearRegModelSerializer, PureModelSerializer, PureLayerSerializer, model_serializers, layer_serializers, \
    UserAvatarSerializer
from rest_framework import permissions
from .permissions import IsOwner, IsNotBeingTrainedOrReadOnly
from rest_framework.authtoken.models import Token
from ml_server import train_model, get_data_info, get_model_info

User = get_user_model()


class ModelTrainView(APIView):
    permission_classes = [permissions.IsAuthenticated, IsOwner]

    def post(self, request, model_pk, format=None):
        try:
            model = Model.objects.get(pk=model_pk)
            self.check_object_permissions(request, model)  # raise an exception if the user doesn't own the model
            serializer = ModelTrainSerializer(data=request.data)
            if serializer.is_valid():
                user = self.request.user
                user_id = User.objects.get(username=user).id
                data_id = serializer.validated_data['data']
                data = Data.objects.get(pk=data_id)
                self.check_object_permissions(request, data)  # raise an exception if the user doesn't own the data
                model_type = model.type
                args = {}
                fields = ['to_drop', 'y_col', 'test_size', 'normalization_method']
                if model_type == "linearreg":
                    args['normalize'] = model.normalize
                    args['fit_intercept'] = model.fit_intercept

                elif model_type == 'decisiontree_cls' or model_type == 'decisiontree_reg':
                    # 'max_depth', 'max_features', 'criterion', 'splitter'
                    max_features = model.max_features
                    try:
                        args['max_features'] = int(max_features)
                    except ValueError:
                        try:
                            args['max_features'] = float(max_features)
                        except ValueError:
                            if max_features is None or max_features in ('auto', 'sqrt', 'log2',):
                                args['max_features'] = max_features
                            else:
                                return JsonResponse({'detail': 'Value for Max Features is invalid'},
                                                    status=status.HTTP_400_BAD_REQUEST)
                    args['max_depth'] = model.max_depth
                    args['criterion'] = model.criterion
                    args['splitter'] = model.splitter

                elif model_type == 'randomforest_cls' or model_type == 'randomforest_reg':
                    max_features = model.max_features
                    try:
                        args['max_features'] = int(max_features)
                    except ValueError:
                        try:
                            args['max_features'] = float(max_features)
                        except ValueError:
                            if max_features is None or max_features in ('auto', 'sqrt', 'log2',):
                                args['max_features'] = max_features
                            else:
                                return JsonResponse({'detail': 'Value for Max Features is invalid'},
                                                    status=status.HTTP_400_BAD_REQUEST)
                    args['n_estimators'] = model.n_estimators
                    args['max_depth'] = model.max_depth
                    args['criterion'] = model.criterion
                    args['bootstrap'] = model.bootstrap
                    if model_type == 'randomforest_cls':
                        args['class_weight'] = model.class_weight
                    args['ccp_alpha'] = model.ccp_alpha

                elif model_type == 'knn_cls' or model_type == 'knn_reg':
                    args['n_neighbors'] = model.n_neighbors
                    args['weights'] = model.weights
                    args['algorithm'] = model.algorithm

                elif model_type == 'mpl_cls' or model_type == 'mpl_reg':
                    try:
                        hidden_layer_sizes = json.loads(model.hidden_layer_sizes)
                        if type(hidden_layer_sizes) != list:
                            return JsonResponse({'detail': 'Hidden layer sizes must be a JSON list of integers'},
                                                status=status.HTTP_400_BAD_REQUEST)
                        args['hidden_layer_sizes'] = hidden_layer_sizes
                    except JSONDecodeError:
                        return JsonResponse({'detail': 'Hidden layer sizes must be a JSON list of integers'},
                                            status=status.HTTP_400_BAD_REQUEST)
                    args['max_iter'] = model.max_iter
                    args['activation'] = model.activation
                    args['solver'] = model.solver
                    args['learning_rate'] = model.learning_rate
                    args['learning_rate_init'] = model.learning_rate_init
                    args['tol'] = model.tol
                elif model_type == 'kmeans':
                    args['n_clusters'] = model.n_clusters
                    args['max_iter'] = model.max_iter
                    args['tol'] = model.tol
                    args['algorithm'] = model.algorithm

                for field in fields:
                    if field in serializer.validated_data:
                        args[field] = serializer.validated_data[field]

                # authenticate by sending the privileged token
                privileged_user = User.objects.filter(username='ml')[0]
                token = Token.objects.get(user=privileged_user).key

                # print(token)

                response = train_model(user_id=user_id,
                                       data_id=data_id,
                                       model_id=model_pk,
                                       token=token,
                                       model_type=model_type,
                                       args=args)

                if response.status_code == 202:
                    model.being_trained = True
                    model.save()
                try:
                    return JsonResponse(response.json(), status=response.status_code)
                except JSONDecodeError:
                    return JsonResponse({'detail': 'An error has occurred.'},
                                        status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        except APIException:  # check_object_permissions found that the user doesn't own the model/data
            return JsonResponse({'detail': 'You do not have the permission to perform this action'},
                                status=status.HTTP_403_FORBIDDEN)
        except Model.DoesNotExist:  # Model.objects.get(pk=...) couldn't find a model
            return JsonResponse({'detail': 'Model not found.'},
                                status=status.HTTP_404_NOT_FOUND)
        except Data.DoesNotExist:  # Data.objects.get(pk=...) couldn't find a data
            return JsonResponse({'detail': 'Data not found.'},
                                status=status.HTTP_404_NOT_FOUND)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UserList(viewsets.ReadOnlyModelViewSet):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        queryset = User.objects.filter(id=self.request.user.id)
        return queryset


class UserAvatarUploadView(APIView):
    parser_classes = [MultiPartParser, FormParser]
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, format=None):
        serializer = UserAvatarSerializer(data=request.data, instance=request.user)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UserRegistrationView(APIView):
    permission_classes = []
    authentication_classes = []

    def post(self, request, format=None):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ModelList(APIView):
    permission_classes = [permissions.IsAuthenticated, IsOwner]

    def get(self, request, format=None):
        models = Model.objects.filter(owner=request.user)
        serializer = ModelSerializer(models, many=True)
        return Response(serializer.data)

    def post(self, request, format=None):
        serializer = ModelSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        if "type" not in request.data:
            return JsonResponse({'type': ['This field is required.']}, status=status.HTTP_400_BAD_REQUEST)

        else:
            try:
                serializer = model_serializers[request.data['type']](data=request.data)
            except KeyError:
                return JsonResponse({'detail': 'Invalid model type.'},
                                    status=status.HTTP_400_BAD_REQUEST)
            if not serializer.is_valid():
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
            else:
                try:
                    serializer.save(owner=self.request.user)
                except IntegrityError:
                    return JsonResponse({'detail': 'A model with this name already exists.'},
                                        status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.data, status=status.HTTP_201_CREATED)


class ModelDetail(APIView):
    permission_classes = [permissions.IsAuthenticated, IsOwner, IsNotBeingTrainedOrReadOnly]

    def get(self, request, pk, format=None):
        try:
            model = Model.objects.get(pk=pk)
            self.check_object_permissions(request, model)
            serializer = ModelSerializer(model)
            return Response(serializer.data)

        except Model.DoesNotExist:
            return JsonResponse({'detail': 'Not found.'},
                                status=status.HTTP_404_NOT_FOUND)
        except APIException:  # check_object_permissions found that the user doesn't own the model/data
            return JsonResponse({'detail': 'You do not have the permission to perform this action'},
                                status=status.HTTP_403_FORBIDDEN)

    def put(self, request, pk, format=None):
        try:
            model = Model.objects.get(pk=pk)
            self.check_object_permissions(request, model)
            try:
                serializer = model_serializers[model.type](model, data=request.data)
            except KeyError:
                return JsonResponse({'detail': 'Invalid model type.'},
                                    status=status.HTTP_400_BAD_REQUEST)
            if not serializer.is_valid():
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
            try:
                serializer.save(type=model.type, owner=self.request.user)
            except IntegrityError:
                return JsonResponse({'detail': 'A model with this name already exists'},
                                    status=status.HTTP_400_BAD_REQUEST)
            return Response(serializer.data, status=status.HTTP_200_OK)

        except Model.DoesNotExist:
            return JsonResponse({'detail': 'Not found.'},
                                status=status.HTTP_404_NOT_FOUND)
        except APIException:  # check_object_permissions found that the user doesn't own the model/data
            return JsonResponse({'detail': 'You do not have the permission to perform this action'},
                                status=status.HTTP_403_FORBIDDEN)

    def delete(self, request, pk, format=None):
        try:
            model = Model.objects.get(pk=pk)
            self.check_object_permissions(request, model)
            model.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)

        except Model.DoesNotExist:
            return JsonResponse({'detail': 'Not found.'},
                                status=status.HTTP_404_NOT_FOUND)
        except APIException:  # check_object_permissions found that the user doesn't own the model/data
            return JsonResponse({'detail': 'You do not have the permission to perform this action'},
                                status=status.HTTP_403_FORBIDDEN)


class LayerList(APIView):
    permission_classes = [permissions.IsAuthenticated, IsOwner]

    def get(self, request, model_pk, format=None):
        try:
            model = Model.objects.get(pk=model_pk)
            if model.type != 'neural':
                return JsonResponse({'detail': 'Model is not a neural network model.'},
                                    status=status.HTTP_403_FORBIDDEN)
            layers = Layer.objects.filter(owner=request.user).filter(neuralModel=model)
            serializer = LayerSerializer(layers, many=True)
            return Response(serializer.data)
        except Model.DoesNotExist:
            return JsonResponse({'detail': 'Model not found.'},
                                status=status.HTTP_404_NOT_FOUND)

    def post(self, request, model_pk, format=None):
        try:
            model = Model.objects.get(pk=model_pk)
            if model.type != 'neural':
                return JsonResponse({'detail': 'Model is not a neural network model.'},
                                    status=status.HTTP_403_FORBIDDEN)
            serializer = LayerSerializer(data=request.data)
            if not serializer.is_valid():
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

            if "type" not in request.data:
                return JsonResponse({'type': ['This field is required.']}, status=status.HTTP_400_BAD_REQUEST)

            else:
                serializer = layer_serializers[request.data['type']](data=request.data)
                if not serializer.is_valid():
                    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
                else:
                    serializer.save(owner=self.request.user, neuralModel=model)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        except Model.DoesNotExist:
            return JsonResponse({'detail': 'Model not found.'},
                                status=status.HTTP_404_NOT_FOUND)


class LayerDetail(APIView):
    permission_classes = [permissions.IsAuthenticated, IsOwner, IsNotBeingTrainedOrReadOnly]

    def get(self, request, model_pk, pk, format=None):
        try:
            model = Model.objects.get(pk=model_pk)
            self.check_object_permissions(request, model)
            if model.type != 'neural':
                return JsonResponse({'detail': 'Model is not a neural network model.'},
                                    status=status.HTTP_403_FORBIDDEN)
            layer = Layer.objects.filter(neuralModel=model).get(pk=pk)
            serializer = LayerSerializer(layer)
            return Response(serializer.data)

        except Model.DoesNotExist:
            return JsonResponse({'detail': 'Model not found.'},
                                status=status.HTTP_404_NOT_FOUND)
        except Layer.DoesNotExist:
            return JsonResponse({'detail': 'Not found.'},
                                status=status.HTTP_404_NOT_FOUND)
        except APIException:  # check_object_permissions found that the user doesn't own the model/data
            return JsonResponse({'detail': 'You do not have the permission to perform this action'},
                                status=status.HTTP_403_FORBIDDEN)

    def put(self, request, model_pk, pk, format=None):
        try:
            model = Model.objects.get(pk=model_pk)
            self.check_object_permissions(request, model)
            if model.type != 'neural':
                return JsonResponse({'detail': 'Model is not a neural network model.'},
                                    status=status.HTTP_403_FORBIDDEN)
            layer = Layer.objects.filter(neuralModel=model).get(pk=pk)
            serializer = layer_serializers[layer.type](layer, data=request.data)
            if not serializer.is_valid():
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
            serializer.save(type=layer.type, owner=self.request.user)
            return Response(serializer.data, status=status.HTTP_200_OK)

        except Model.DoesNotExist:
            return JsonResponse({'detail': 'Model not found.'},
                                status=status.HTTP_404_NOT_FOUND)
        except Layer.DoesNotExist:
            return JsonResponse({'detail': 'Not found.'},
                                status=status.HTTP_404_NOT_FOUND)
        except APIException:  # check_object_permissions found that the user doesn't own the model/data
            return JsonResponse({'detail': 'You do not have the permission to perform this action'},
                                status=status.HTTP_403_FORBIDDEN)

    def delete(self, request, model_pk, pk, format=None):
        try:
            model = Model.objects.get(pk=model_pk)
            self.check_object_permissions(request, model)
            if model.type != 'neural':
                return JsonResponse({'detail': 'Model is not a neural network model.'},
                                    status=status.HTTP_403_FORBIDDEN)
            layer = Layer.objects.filter(neuralModel=model).get(pk=pk)
            layer.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except Model.DoesNotExist:
            return JsonResponse({'detail': 'Model not found.'},
                                status=status.HTTP_404_NOT_FOUND)
        except Layer.DoesNotExist:
            return JsonResponse({'detail': 'Not found.'},
                                status=status.HTTP_404_NOT_FOUND)
        except APIException:  # check_object_permissions found that the user doesn't own the model/data
            return JsonResponse({'detail': 'You do not have the permission to perform this action'},
                                status=status.HTTP_403_FORBIDDEN)


class DataList(viewsets.ModelViewSet):
    serializer_class = DataSerializer
    permission_classes = [permissions.IsAuthenticated, IsOwner]

    def perform_create(self, serializer):
        try:
            serializer.save(owner=self.request.user)
        except IntegrityError:
            raise ValidationError({
                'detail': 'A data set with this name already exists'
            })

    def perform_update(self, serializer):
        try:
            serializer.save(owner=self.request.user)
        except IntegrityError:
            raise ValidationError({
                'detail': 'A data set with this name already exists'
            })

    def get_queryset(self):
        user = self.request.user
        return Data.objects.filter(owner=user)


class DataInfoLView(APIView):
    permission_classes = [permissions.IsAuthenticated, IsOwner]

    def get(self, request, data_pk, format=None):
        try:
            data = Data.objects.get(pk=data_pk)
            self.check_object_permissions(request, data)

            # authenticate by sending the privileged token
            privileged_user = User.objects.filter(username='ml')[0]
            token = Token.objects.get(user=privileged_user).key

            response = get_data_info(data_id=data.id, user_id=request.user.id, token=token)
            return JsonResponse(response.json(), status=response.status_code)

        except Data.DoesNotExist:
            return JsonResponse({'detail': 'Not found.'},
                                status=status.HTTP_404_NOT_FOUND)
        except APIException:  # check_object_permissions found that the user doesn't own the model/data
            return JsonResponse({'detail': 'You do not have the permission to perform this action'},
                                status=status.HTTP_403_FORBIDDEN)


class ModelInfoView(APIView):
    permission_classes = [permissions.IsAuthenticated, IsOwner]

    def get(self, request, data_pk, format=None):
        try:
            model = Model.objects.get(pk=data_pk)
            self.check_object_permissions(request, model)
            if model.being_trained:
                return JsonResponse({
                    'detail': 'Cannot obtain information about the trained model while it\'s being trained.'
                },
                                    status=status.HTTP_403_FORBIDDEN)

            # authenticate by sending the privileged token
            privileged_user = User.objects.filter(username='ml')[0]
            token = Token.objects.get(user=privileged_user).key

            response = get_model_info(model_id=model.id, user_id=request.user.id, token=token)
            return JsonResponse(response.json(), status=response.status_code)

        except Model.DoesNotExist:
            return JsonResponse({'detail': 'Not found.'},
                                status=status.HTTP_404_NOT_FOUND)
        except APIException:  # check_object_permissions found that the user doesn't own the model/data
            return JsonResponse({'detail': 'You do not have the permission to perform this action'},
                                status=status.HTTP_403_FORBIDDEN)


class DeviceList(viewsets.ModelViewSet):
    serializer_class = DeviceSerializer
    permission_classes = [permissions.IsAuthenticated, IsOwner]

    def perform_create(self, serializer):
        try:
            serializer.save(owner=self.request.user)
        except IntegrityError:
            raise ValidationError({
                'detail': 'A channel_id is already registered for this user.'
            })

    def perform_update(self, serializer):
        try:
            serializer.save(owner=self.request.user)
        except IntegrityError:
            raise ValidationError({
                'detail': 'A channel_id is already registered for this user.'
            })

    def get_queryset(self):
        user = self.request.user
        return Device.objects.filter(owner=user)


class DeviceByChannelIdView(APIView):
    permission_classes = [permissions.IsAuthenticated, IsOwner]

    def get(self, request, channel_id, format=None):
        try:
            device = Device.objects.get(owner=request.user, channel_id=channel_id)
            self.check_object_permissions(request, device)
            serializer = DeviceSerializer(device)
            return Response(serializer.data)

        except Device.DoesNotExist:
            return JsonResponse({'detail': 'Not found.'},
                                status=status.HTTP_404_NOT_FOUND)
        except APIException:  # check_object_permissions found that the user doesn't own the model/data
            return JsonResponse({'detail': 'You do not have the permission to perform this action'},
                                status=status.HTTP_403_FORBIDDEN)

    def put(self, request, channel_id, format=None):
        try:
            device = Device.objects.get(owner=request.user, channel_id=channel_id)
            self.check_object_permissions(request, device)
            serializer = DeviceSerializer(device, data=request.data)
            if not serializer.is_valid():
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
            serializer.save(owner=self.request.user)
            return Response(serializer.data, status=status.HTTP_200_OK)

        except Device.DoesNotExist:
            return JsonResponse({'detail': 'Not found.'},
                                status=status.HTTP_404_NOT_FOUND)
        except APIException:  # check_object_permissions found that the user doesn't own the model/data
            return JsonResponse({'detail': 'You do not have the permission to perform this action'},
                                status=status.HTTP_403_FORBIDDEN)

    def delete(self, request, channel_id, format=None):
        try:
            device = Device.objects.get(channel_id=channel_id)
            self.check_object_permissions(request, device)
            device.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)

        except Device.DoesNotExist:
            return JsonResponse({'detail': 'Not found.'},
                                status=status.HTTP_404_NOT_FOUND)
        except APIException:  # check_object_permissions found that the user doesn't own the model/data
            return JsonResponse({'detail': 'You do not have the permission to perform this action'},
                                status=status.HTTP_403_FORBIDDEN)

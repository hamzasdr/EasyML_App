from collections import OrderedDict

from django.contrib.auth import get_user_model
from rest_framework.fields import SkipField
from rest_framework import serializers

from .models import Layer, ConvLayer, DenseLayer, NeuralModel, Model, Data, Device, LinearRegModel, \
    DecisionTreeClassifierModel, KNearestNeighborsClassifierModel, MultiLayerPerceptronClassifierModel, \
    RandomForestClassifierModel, DecisionTreeRegressorModel, KNearestNeighborsRegressorModel, \
    RandomForestRegressorModel, MultiLayerPerceptronRegressorModel, KMeansModel

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True, style={'input-type': 'password'})
    avatar = serializers.ImageField(allow_empty_file=True, allow_null=True, required=False, use_url=True)

    class Meta:
        model = User
        fields = ('username', 'email', 'password', 'avatar')

    def create(self, validated_data):
        user = super().create(validated_data)
        user.set_password(validated_data['password'])
        user.save()
        return user

    def update(self, instance, validated_data):
        user = super().update(instance, validated_data)
        if 'password' in validated_data:
            user.set_password(validated_data['password'])
            user.save()
        return user


class UserAvatarSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["avatar"]

    def save(self, *args, **kwargs):
        if self.instance.avatar:
            self.instance.avatar.delete()
        return super().save(**kwargs)


class ModelSerializer(serializers.ModelSerializer):
    # id = serializers.IntegerField(read_only=False)
    # name = serializers.CharField(max_length=25, read_only=False)
    owner = serializers.ReadOnlyField(source='owner.username')
    being_trained = serializers.BooleanField(read_only=True)
    type = serializers.CharField(required=False)

    class Meta:
        model = Model
        exclude = ['polymorphic_ctype']

    def to_representation(self, instance):
        if isinstance(instance, LinearRegModel):
            return LinearRegModelSerializer(instance=instance).data
        elif isinstance(instance, NeuralModel):
            return NeuralModelSerializer(instance=instance).data
        elif isinstance(instance, KNearestNeighborsClassifierModel):
            return KNearestNeighborsClassifierModelSerializer(instance=instance).data
        elif isinstance(instance, DecisionTreeClassifierModel):
            return DecisionTreeClassifierModelSerializer(instance=instance).data
        elif isinstance(instance, RandomForestClassifierModel):
            return RandomForestClassifierModelSerializer(instance=instance).data
        elif isinstance(instance, MultiLayerPerceptronClassifierModel):
            return MultiLayerPerceptronClassifierModelSerializer(instance=instance).data
        elif isinstance(instance, KNearestNeighborsRegressorModel):
            return KNearestNeighborsRegressorModelSerializer(instance=instance).data
        elif isinstance(instance, DecisionTreeRegressorModel):
            return DecisionTreeRegressorModelSerializer(instance=instance).data
        elif isinstance(instance, RandomForestRegressorModel):
            return RandomForestRegressorModelSerializer(instance=instance).data
        elif isinstance(instance, MultiLayerPerceptronRegressorModel):
            return MultiLayerPerceptronRegressorModelSerializer(instance=instance).data
        elif isinstance(instance, KMeansModel):
            return KMeansModelSerializer(instance=instance).data
        else:
            return PureModelSerializer(instance=instance).data


class PureModelSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    being_trained = serializers.BooleanField(read_only=True)
    type = serializers.CharField(required=False)

    class Meta:
        model = Model
        # fields = '__all__'
        exclude = ['polymorphic_ctype']


class LinearRegModelSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    being_trained = serializers.BooleanField(read_only=True)
    type = serializers.CharField(required=False)

    class Meta:
        model = LinearRegModel
        exclude = ['polymorphic_ctype']


class DecisionTreeClassifierModelSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    being_trained = serializers.BooleanField(read_only=True)
    type = serializers.CharField(required=False)

    class Meta:
        model = DecisionTreeClassifierModel
        exclude = ['polymorphic_ctype']


class KNearestNeighborsClassifierModelSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    being_trained = serializers.BooleanField(read_only=True)
    type = serializers.CharField(required=False)

    class Meta:
        model = KNearestNeighborsClassifierModel
        exclude = ['polymorphic_ctype']


class RandomForestClassifierModelSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    being_trained = serializers.BooleanField(read_only=True)
    type = serializers.CharField(required=False)

    class Meta:
        model = RandomForestClassifierModel
        exclude = ['polymorphic_ctype']


class MultiLayerPerceptronClassifierModelSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    being_trained = serializers.BooleanField(read_only=True)
    type = serializers.CharField(required=False)

    class Meta:
        model = MultiLayerPerceptronClassifierModel
        exclude = ['polymorphic_ctype']


class DecisionTreeRegressorModelSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    being_trained = serializers.BooleanField(read_only=True)
    type = serializers.CharField(required=False)

    class Meta:
        model = DecisionTreeRegressorModel
        exclude = ['polymorphic_ctype']


class KNearestNeighborsRegressorModelSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    being_trained = serializers.BooleanField(read_only=True)
    type = serializers.CharField(required=False)

    class Meta:
        model = KNearestNeighborsRegressorModel
        exclude = ['polymorphic_ctype']


class RandomForestRegressorModelSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    being_trained = serializers.BooleanField(read_only=True)
    type = serializers.CharField(required=False)

    class Meta:
        model = RandomForestRegressorModel
        exclude = ['polymorphic_ctype']


class MultiLayerPerceptronRegressorModelSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    being_trained = serializers.BooleanField(read_only=True)
    type = serializers.CharField(required=False)

    class Meta:
        model = MultiLayerPerceptronRegressorModel
        exclude = ['polymorphic_ctype']


class KMeansModelSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    being_trained = serializers.BooleanField(read_only=True)
    type = serializers.CharField(required=False)

    class Meta:
        model = KMeansModel
        exclude = ['polymorphic_ctype']


class LayerSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    type = serializers.CharField(required=False)

    class Meta:
        model = Layer
        exclude = ['polymorphic_ctype']

    def to_representation(self, instance):
        if isinstance(instance, DenseLayer):
            return DenseLayerSerializer(instance=instance).data
        elif isinstance(instance, ConvLayer):
            return ConvLayerSerializer(instance=instance).data
        else:
            return PureLayerSerializer(instance=instance).data


# THIS IS  U G L Y  :(
class NeuralModelSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    being_trained = serializers.BooleanField(read_only=True)
    layers = serializers.ListField(required=False)
    type = serializers.CharField(required=False)

    # for getting
    def to_representation(self, instance):
        # get the data for all neural fields expect the list
        data = PureNeuralModelSerializer(instance=instance).data
        layers = list(instance.layers.get_queryset())
        data['layers'] = [LayerSerializer(layer).data for layer in layers]
        return data

    # for posting
    def create(self, validated_data):
        serializer_list = []
        if 'layers' in validated_data:
            for layer in validated_data['layers']:
                layer_serializer = LayerSerializer(data=layer)
                if layer_serializer.is_valid():
                    layer_serializer = layer_serializers[layer_serializer.validated_data['type']](data=layer)
                    if layer_serializer.is_valid():
                        serializer_list.append(layer_serializer)
                    else:
                        raise serializers.ValidationError(layer_serializer.errors)
                else:
                    raise serializers.ValidationError(layer_serializer.errors)
        data = {key: validated_data[key] for key in validated_data if key != 'layers'}
        neural_model = NeuralModel.objects.create(**data)
        for layer_serializer in serializer_list:
            layer_serializer.save(neuralModel=neural_model, owner=validated_data['owner'])
        return neural_model

    class Meta:
        model = NeuralModel
        # fields = '__all__'
        exclude = ['polymorphic_ctype']


# this class represents all neural fields but the layers list
class PureNeuralModelSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    being_trained = serializers.BooleanField(read_only=True)
    type = serializers.CharField(required=False)

    class Meta:
        model = NeuralModel
        # fields = '__all__'
        exclude = ['polymorphic_ctype']


class PureLayerSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    type = serializers.CharField(required=False)

    class Meta:
        model = Layer
        exclude = ['polymorphic_ctype']


class DenseLayerSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    type = serializers.CharField(required=False)

    class Meta:
        model = DenseLayer
        exclude = ['polymorphic_ctype']
        # extra_kwargs = {
        #     'layer': {'validators': []}}


class ConvLayerSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    type = serializers.CharField(required=False)

    class Meta:
        model = ConvLayer
        exclude = ['polymorphic_ctype']
        # extra_kwargs = {
        #     'layer': {'validators': []}}


class DataSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')

    class Meta:
        model = Data
        fields = '__all__'


class ModelTrainSerializer(serializers.Serializer):
    data = serializers.IntegerField(required=True)
    test_size = serializers.FloatField(required=False)
    to_drop = serializers.ListField(required=False,
                                    child=serializers.CharField())
    y_col = serializers.CharField(required=False, allow_null=True)
    normalization_method = serializers.CharField(required=False, allow_null=True)

    def create(self, validated_data):
        pass

    def update(self, instance, validated_data):
        pass


class DeviceSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username', required=False)

    class Meta:
        model = Device
        fields = '__all__'


model_serializers = {
    # 'model': PureModelSerializer,
    'linearreg': LinearRegModelSerializer,
    'neural': NeuralModelSerializer,

    'decisiontree_cls': DecisionTreeClassifierModelSerializer,
    'randomforest_cls': RandomForestClassifierModelSerializer,
    'knn_cls': KNearestNeighborsClassifierModelSerializer,
    'mpl_cls': MultiLayerPerceptronClassifierModelSerializer,

    'decisiontree_reg': DecisionTreeRegressorModelSerializer,
    'randomforest_reg': RandomForestRegressorModelSerializer,
    'knn_reg': KNearestNeighborsRegressorModelSerializer,
    'mpl_reg': MultiLayerPerceptronRegressorModelSerializer,

    'kmeans': KMeansModelSerializer
}

layer_serializers = {
    # 'layer': PureLayerSerializer,
    'dense': DenseLayerSerializer,
    'conv': ConvLayerSerializer
}
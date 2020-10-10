import os

from django.conf import settings
from django.core.validators import RegexValidator, MinValueValidator
from django.db import models
from django.utils import timezone
from django.contrib.auth.models import AbstractUser
from .enums import FileType, DeviceType, ModelType, LayerType
from polymorphic.models import PolymorphicModel

from django.utils.translation import gettext_lazy as _

from .validators import validate_hidden_layers, validate_max_features

user_class_name = 'myapi.CustomUser'


def upload_to(instance, filename):
    now = timezone.now()
    base, extension = os.path.splitext(filename.lower())
    milliseconds = now.microsecond // 1000
    return f"users/{instance.pk}/{now:%Y%m%d%H%M%S}{milliseconds}{extension}"


class CustomUser(AbstractUser):
    email = models.EmailField(unique=True, blank=False, null=False,  error_messages={
            'unique': "A user with that email already exists.",
        },)
    avatar = models.ImageField(_("Avatar"), upload_to=upload_to, blank=True, null=True)
    is_privileged = models.BooleanField(default=False, null=False)


class Model(PolymorphicModel):
    class Meta:
        unique_together = ('name', 'owner')
    name = models.CharField(max_length=200, unique=False)
    owner = models.ForeignKey(user_class_name, on_delete=models.CASCADE, related_name='%(class)s_user')
    type = models.CharField(max_length=25, choices=ModelType.choices(), null=False)
    being_trained = models.BooleanField(default=False)

    def __str__(self):
        return self.name


class NeuralModel(Model):
    epochs = models.CharField(max_length=50)
    optimizer = models.CharField(max_length=30)

    def __str__(self):
        return self.name


class LinearRegModel(Model):
    fit_intercept = models.BooleanField(default=True)
    normalize = models.BooleanField(default=False)

    def __str__(self):
        return self.name


class DecisionTreeClassifierModel(Model):
    max_depth = models.IntegerField(default=None, null=True, validators=[MinValueValidator(1)])
    max_features = models.CharField(default="auto", max_length=100, validators=[validate_max_features])
    criterion = models.CharField(default="gini",
                                 choices=(("gini", "Gini Impurity",), ("entropy", "Entropy",),),
                                 max_length=20)
    splitter = models.CharField(default="best", choices=(("best", "Best",), ("random", "Random",),), max_length=20)


class RandomForestClassifierModel(Model):
    n_estimators = models.IntegerField(default=100, validators=[MinValueValidator(1)])
    max_depth = models.IntegerField(default=None, null=True, validators=[MinValueValidator(1)])
    max_features = models.CharField(default="auto", max_length=100, validators=[validate_max_features])
    criterion = models.CharField(default="gini",
                                 choices=(("gini", "Gini Impurity",), ("entropy", "Entropy",),),
                                 max_length=20)
    bootstrap = models.BooleanField(default=True)
    class_weight = models.CharField(default="balanced",
                                    choices=(("balanced", "Balanced",), ("balanced_subsample", "Balanced Subsample")),
                                    max_length=100)
    ccp_alpha = models.FloatField(default=0.0, null=True, validators=[MinValueValidator(0.0)])


class KNearestNeighborsClassifierModel(Model):
    n_neighbors = models.IntegerField(default=5, validators=[MinValueValidator(1)])
    weights = models.CharField(default="uniform",
                               choices=(("uniform", "Uniform",), ("distance", "Distance",),),
                               max_length=20)
    algorithm = models.CharField(default="auto",
                                 choices=(
                                     ("auto", "Auto",),
                                     ("ball_tree", "Ball Tree"),
                                     ("kd_tree", "K dimensional tree",),
                                     ("brute", "Brute Force",),),
                                 max_length=20)


class MultiLayerPerceptronClassifierModel(Model):
    hidden_layer_sizes = models.CharField(default="[100]", max_length=500, validators=[validate_hidden_layers])
    max_iter = models.IntegerField(default=200, validators=[MinValueValidator(1)])
    activation = models.CharField(default="relu",
                                  choices=(
                                      ("identity", "No-op activation",),
                                      ("logistic", "Logistic Sigmoid",),
                                      ("tanh", "Hyperbloic Tan",),
                                      ("relu", "Rectified Linear Unit",)),
                                  max_length=20)
    solver = models.CharField(default="adam",
                              choices=(
                                  ("lbfgs", "Limited-memory Broyden–Fletcher–Goldfarb–Shanno algorithm",),
                                  ("sgd", "Stochastic Gradient Descent",),
                                  ("adam", "Adam",)),
                              max_length=20)
    learning_rate = models.CharField(default="constant",
                                     choices=(
                                         ("constant", "Constant",),
                                         ("invscaling", "Inverse Scaling Exponent",),
                                         ("adaptive", "Adaptive"),
                                     ),
                                     max_length=20)
    learning_rate_init = models.FloatField(default=0.001)
    tol = models.FloatField(default=0.0001)


class DecisionTreeRegressorModel(Model):
    max_depth = models.IntegerField(default=None, null=True, validators=[MinValueValidator(1)])
    max_features = models.CharField(default="auto", max_length=100, validators=[validate_max_features])
    criterion = models.CharField(default="mse",
                                 choices=(("mse", "Mean Square Error",),
                                          ("friedman_mse", "Friedman’s improved Mean Square Error",),
                                          ("mae", "Mean Absolute Error",),),
                                 max_length=20)
    splitter = models.CharField(default="best", choices=(("best", "Best",), ("random", "Random",),), max_length=20)


class RandomForestRegressorModel(Model):
    n_estimators = models.IntegerField(default=100, validators=[MinValueValidator(1)])
    max_depth = models.IntegerField(default=None, null=True, validators=[MinValueValidator(1)])
    max_features = models.CharField(default="auto", max_length=100, validators=[validate_max_features])
    criterion = models.CharField(default="mse",
                                 choices=(("mse", "Mean Square Error",),
                                          ("mae", "Mean Absolute Error",),),
                                 max_length=20)
    bootstrap = models.BooleanField(default=True)
    ccp_alpha = models.FloatField(default=0.0, null=True, validators=[MinValueValidator(0.0)])


class KNearestNeighborsRegressorModel(Model):
    n_neighbors = models.IntegerField(default=5, validators=[MinValueValidator(1)])
    weights = models.CharField(default="uniform",
                               choices=(("uniform", "Uniform",), ("distance", "Distance",),),
                               max_length=20)
    algorithm = models.CharField(default="auto",
                                 choices=(
                                     ("auto", "Auto",),
                                     ("ball_tree", "Ball Tree"),
                                     ("kd_tree", "K dimensional tree",),
                                     ("brute", "Brute Force",),),
                                 max_length=20)


class MultiLayerPerceptronRegressorModel(Model):
    hidden_layer_sizes = models.CharField(default="[100]", max_length=500, validators=[validate_hidden_layers])
    max_iter = models.IntegerField(default=200, validators=[MinValueValidator(1)])
    activation = models.CharField(default="relu",
                                  choices=(
                                      ("identity", "No-op activation",),
                                      ("logistic", "Logistic Sigmoid",),
                                      ("tanh", "Hyperbloic Tan",),
                                      ("relu", "Rectified Linear Unit",)),
                                  max_length=20)
    solver = models.CharField(default="adam",
                              choices=(
                                  ("lbfgs", "Limited-memory Broyden–Fletcher–Goldfarb–Shanno algorithm",),
                                  ("sgd", "Stochastic Gradient Descent",),
                                  ("adam", "Adam",)),
                              max_length=20)
    learning_rate = models.CharField(default="constant",
                                     choices=(
                                         ("constant", "Constant",),
                                         ("invscaling", "Inverse Scaling Exponent",),
                                         ("adaptive", "Adaptive"),
                                     ),
                                     max_length=20)
    learning_rate_init = models.FloatField(default=0.001)
    tol = models.FloatField(default=0.0001)

class KMeansModel(Model):
    n_clusters = models.IntegerField(default=8, validators=[MinValueValidator(2)])
    max_iter = models.IntegerField(default=300, validators=[MinValueValidator(1)])
    tol = models.FloatField(default=0.0001, validators=[MinValueValidator(0)])
    algorithm = models.CharField(default="auto",
                                 choices=(
                                     ("auto", "Auto",),
                                     ("full", "Classical EM-style algorithm"),
                                     ("elkan", "Triangle Inequality",),),
                                 max_length=20)


class Layer(PolymorphicModel):
    type = models.CharField(max_length=20, choices=LayerType.choices())
    activationFunction = models.CharField(max_length=20)
    neuralModel = models.ForeignKey("NeuralModel", related_name='layers', on_delete=models.CASCADE, null=True, blank=True)
    owner = models.ForeignKey(user_class_name, on_delete=models.CASCADE, related_name='%(class)s_user')

    def __str__(self):
        return str(self.id)


class DenseLayer(Layer):
    numberOfNodes = models.IntegerField()

    def __str__(self):
        return str(self.id)


class ConvLayer(Layer):
    filter = models.IntegerField()
    kernel1 = models.IntegerField()
    kernel2 = models.IntegerField()

    def __str__(self):
        return str(self.id)


class Data(models.Model):
    name = models.CharField(max_length=200, null=False)
    type = models.CharField(max_length=30, null=False, choices=FileType.choices())
    owner = models.ForeignKey(user_class_name, on_delete=models.CASCADE, related_name='%(class)s_user')

    class Meta:
        unique_together = ('name', 'owner')


# register devices for user to send notifications to
class Device(models.Model):
    # this is a uuid used to target the user through the notification service
    # the regex validator is to validate that the format is uuid format
    channel_id = models.CharField(max_length=50, null=False, unique=False, validators=[
        RegexValidator(regex="[0-9a-fA-F]{8}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{12}",
                       message="Enter a valid uuid")
    ])
    device_type = models.CharField(max_length=20, choices=DeviceType.choices(), null=False)
    logged_in = models.BooleanField(default=False)
    owner = models.ForeignKey(user_class_name, on_delete=models.CASCADE, related_name='%(class)s_user')

    class Meta:
        unique_together = ('channel_id', 'owner')

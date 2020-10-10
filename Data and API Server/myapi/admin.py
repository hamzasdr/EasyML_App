from django.contrib import admin
from .models import Layer, DenseLayer, ConvLayer, NeuralModel, Model, ModelType
from django.contrib.auth import get_user_model

admin.site.register(get_user_model())
admin.site.register(Layer)
admin.site.register(Model)
admin.site.register(NeuralModel)
admin.site.register(DenseLayer)
admin.site.register(ConvLayer)

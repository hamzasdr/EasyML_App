from django import forms
from .models import Layer
from .models import DenseLayer

class Layerform(forms.ModelForm):
    class Meta:
        model = Layer
        fields = '__all__'


class denseform(forms.ModelForm):
    class Meta:
        model = DenseLayer
        fields = '__all__'


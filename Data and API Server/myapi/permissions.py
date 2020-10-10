from rest_framework import permissions
from rest_framework.permissions import SAFE_METHODS

WRITE_METHODS = ("POST", "PUT",)


class IsOwner(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj.owner == request.user


class WriteOnly(permissions.BasePermission):
    def has_permission(self, request, view):

        return request.method in WRITE_METHODS


class PostOnly(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.method == 'POST'


class IsNotBeingTrainedOrReadOnly(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        return request.method in SAFE_METHODS or obj.being_trained is False

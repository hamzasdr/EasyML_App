from rest_framework import permissions


class IsPrivileged(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        return request.user.is_privileged

    def has_permission(self, request, view):
        return request.user.is_privileged

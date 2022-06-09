from rest_framework import viewsets, status
from rest_framework.decorators import api_view
from rest_framework.permissions import IsAuthenticated as IsAuth, AllowAny
from rest_framework.response import Response

from django.contrib.auth.models import User

from server import settings
from .models import Profile, Member
from .serializers import UserSerializer, ProfileSerializer, MemberSerializer
from api.permissions import (
    IsOwner,
)

from api.gcs import download_blob

from messaging.twilio_helper import (
    send_intro_text,
    is_valid_number,
)

from messaging.sendgrid_email import (
    send_intro_email,
)


class CurrentUserView(viewsets.ModelViewSet):
    queryset = User.objects.all().order_by('id')
    serializer_class = UserSerializer
    permission_classes = [AllowAny]
    allowed_methods = ['GET']

    def list(self, request, *args, **kwargs):
        queryset = self.filter_queryset(self.get_queryset())

        if request.user.is_authenticated:
            queryset = queryset.filter(id=request.user.id)
        else:
            queryset = queryset.none()

        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)


class UsersView(viewsets.ModelViewSet):
    queryset = User.objects.all().order_by('id')
    serializer_class = UserSerializer
    permission_classes = [IsAuth]
    allowed_methods = ['GET']

    def list(self, request, *args, **kwargs):
        queryset = self.filter_queryset(self.get_queryset())

        # if 'email' in request.query_params:
        #     queryset = queryset.filter(email=request.query_params['email'])
        # elif 'username' in request.query_params:
        #     queryset = queryset.filter(username=request.query_params['username'])
        if not request.user.is_staff:
            queryset = queryset.filter(id=request.user.id)

        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)


class MemberView(viewsets.ModelViewSet):
    queryset = Member.objects.all().order_by('id')
    serializer_class = MemberSerializer
    permission_classes = [IsAuth]

    def create(self, request, *args, **kwargs):
        if Member.objects.filter(owner=request.user.id).exists():
            content = {"error": "Member account already exists"}
            return Response(content, status=status.HTTP_409_CONFLICT)

        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        serializer.validated_data['owner'] = request.user
        self.perform_create(serializer)
        data = serializer.validated_data

        if is_valid_number(data['phone']):
            send_intro_text(data)
            send_intro_email(request.user)

        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)


class ProfilesView(viewsets.ModelViewSet):
    queryset = Profile.objects.all().order_by('-created')
    serializer_class = ProfileSerializer
    permission_classes = [IsAuth, IsOwner]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        serializer.validated_data['owner'] = request.user

        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

    def list(self, request, *args, **kwargs):
        queryset = self.filter_queryset(self.get_queryset())

        if 'username' in request.query_params:
            owner = User.objects.filter(
                username=request.query_params['username'])
            if owner.exists():
                queryset = queryset.filter(owner=owner[0])
            else:
                queryset = queryset.filter(owner=request.user.id)
        else:
            queryset = queryset.filter(owner=request.user.id)

        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)

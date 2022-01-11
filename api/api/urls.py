from django.conf.urls.static import static
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from server import settings
from accounts.views import CurrentUserView, UsersView, ProfilesView, MemberView


router = DefaultRouter()

router.register(r"check", CurrentUserView)
router.register(r"users", UsersView)
router.register(r"profiles", ProfilesView)
router.register(r'members', MemberView)

urlpatterns = [
    path('', include(router.urls)),

    path("rest/", include("rest_framework.urls")),
    path("register/", include("rest_auth.registration.urls")),
    path("auth/", include("rest_auth.urls")),
] + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)

from django.urls import path
from . import views

urlpatterns = [
    path("register", views.register, name='register'),
    path("", views.login_user, name='login'),
    path("default", views.default, name='default'),
    path("about", views.about, name='about'),
    path("temperature", views.temperature, name='temperature'),
    path("humidity", views.humidity, name='humidity'),
    path("gassensor", views.gassensor, name='gassensor'),
    path("phsensor", views.phsensor, name='phsensor'),
    path("profile", views.profile_view, name='profile'),
    path('logout', views.logout_user, name='logout'),
]

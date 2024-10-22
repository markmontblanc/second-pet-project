from django.urls import path
from . import views

urlpatterns = [
    path('test_connection/redis', views.test_connection, name='test_connection'),
]

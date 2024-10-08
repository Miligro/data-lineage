"""
URL configuration for Api project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.urls import path
from . import views

urlpatterns = [
    path('databases/', views.ListDatabasesView.as_view(), name='databases'),
    path('databases/load/', views.LoadDatabasesView.as_view(), name='databases_load'),
    path('databases/<str:database_id>/objects/', views.ListObjectsView.as_view(), name='objects'),
    path('databases/<str:database_id>/objects/<str:object_id>/relationships/',
         views.ListObjectRelationshipsView.as_view(), name='relationships'),
    path('databases/<str:database_id>/objects/<str:object_id>/target_relationships/',
         views.ListObjectRelationshipsTargetView.as_view(), name='relationshipsTarget'),
    path('databases/<str:database_id>/ingest/', views.LineageModelView.as_view(), name='lineage_model'),
]

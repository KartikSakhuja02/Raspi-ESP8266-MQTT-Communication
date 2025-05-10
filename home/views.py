from django.shortcuts import render, redirect
from .models import Register
from django.contrib import messages
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.models import User
from django.contrib.auth.decorators import login_required
from .models import UserProfile
from django.db import IntegrityError


def register(request):
    if request.method == 'POST':
        name = request.POST.get('name')
        email = request.POST.get('email')
        password = request.POST.get('password')
        city = request.POST.get('city')
        pnumber = request.POST.get('pnumber')

        if User.objects.filter(username=name).exists():
            return render(request, 'register.html', {'error': 'Username already taken'})
        if User.objects.filter(email=email).exists():
            return render(request, 'register.html', {'error': 'Email already registered'})

        try:
            user = User.objects.create_user(username=name, email=email, password=password)
            user.save()
            reg = Register(name=name, email=email, password=password, city=city, pnumber=pnumber)
            reg.save()

            return redirect('login')

        except IntegrityError:
            return render(request, 'register.html', {'error': 'Registration failed. Try again.'})


    return render(request, 'register.html')

def login_user(request):
    if request.method == 'POST':
        email = request.POST.get('email')
        password = request.POST.get('password')
        try:
            user = User.objects.get(email=email)
            auth_user = authenticate(request, username=user.username, password=password)
            if auth_user is not None:
                login(request, auth_user)
                return redirect('default')
            else:
                messages.error(request, "Invalid credentials")
        except User.DoesNotExist:
            messages.error(request, "User not found")
    return render(request, 'login.html')

@login_required
def default(request): return render(request, 'home.html')

@login_required
def about(request): return render(request, 'about.html')

@login_required
def temperature(request): return render(request, 'temperature.html')

@login_required
def humidity(request): return render(request, 'humidity.html')

@login_required
def gassensor(request): return render(request, 'gassensor.html')

@login_required
def phsensor(request): return render(request, 'phsensor.html')

@login_required
def profile_view(request):
    user = request.user
    profile, created = UserProfile.objects.get_or_create(user=user)
    cities = ['Pune', 'Mumbai', 'Delhi', 'Bangalore']

    if request.method == 'POST':
        profile.name = request.POST.get('name')
        profile.email = request.POST.get('email')
        profile.phone = request.POST.get('phone')
        profile.city = request.POST.get('city')
        profile.save()

        messages.success(request, "Profile updated successfully!")

        return redirect('profile')
    return render(request, 'profile.html', {
        'user_profile': profile,
        'cities': cities,
    })

def logout_user(request):
    logout(request)
    return redirect('/')

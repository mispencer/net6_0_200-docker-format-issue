#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-broken
WORKDIR /src
COPY ["WebApplication1.csproj", "."]
RUN dotnet restore "./WebApplication1.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "WebApplication1.csproj" -c Release -o /app/build
RUN dotnet format "WebApplication1.csproj"

FROM mcr.microsoft.com/dotnet/sdk:6.0@sha256:329f54fde64e1ce6ea4dd3a17192cc0c97aee394836c5a322751a6d78db511e4 AS build-working
WORKDIR /src
COPY ["WebApplication1.csproj", "."]
RUN dotnet restore "./WebApplication1.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "WebApplication1.csproj" -c Release -o /app/build
RUN dotnet format "WebApplication1.csproj"

FROM build-broken AS publish
RUN dotnet publish "WebApplication1.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "WebApplication1.dll"]
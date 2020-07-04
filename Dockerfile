FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /app

# copy csproj and restore as distinct layers
COPY albiondata-sql-dotNet/*.csproj ./albiondata-sql-dotNet/
WORKDIR /app/albiondata-sql-dotNet
RUN dotnet restore

# copy and publish app and libraries
WORKDIR /app/
COPY albiondata-sql-dotNet/. ./albiondata-sql-dotNet/
WORKDIR /app/albiondata-sql-dotNet
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS runtime
WORKDIR /app
COPY --from=build /app/albiondata-sql-dotNet/out ./

# ENV

ENV DB_SERVER "localhost"
ENV DB_PORT "3306"
ENV DB_NAME "YOUR_DATABASE"
ENV DB_USER "YOUR_DB_USER"
ENV DB_PASSWORD "YOUR_DB_PASSWORD"
ENV NATS_ADDRESS "nats://public:thenewalbiondata@albion-online-data.com:4222"
RUN ls

ENTRYPOINT dotnet albiondata-sql-dotNet.dll-s 'server=${DB_SERVER};port=${DB_PORT};database=${DB_NAME};user=${DB_NAME};password=${DB_PASSWORD}' -s ${NATS_ADDRESS}
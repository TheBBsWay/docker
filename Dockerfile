FROM microsoft/dotnet:2.1-sdk

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \ 
	&& apt update \
	&& apt install -y nodejs \
    && apt install -y sshpass
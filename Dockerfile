FROM microsoft/dotnet:2.1-sdk

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \ 
	&& apt update \
	&& apt install -y nodejs \
    && apt install -y sshpass
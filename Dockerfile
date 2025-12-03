# Use official Swift 5.10+ image (Debian-based for glibc compatibility)
FROM swift:5.10-jammy

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
	git \
	curl \
	tzdata \
	ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

# Configure git for tests
RUN git config --global user.email "test@example.com" && \
	git config --global user.name "Test User"

# Copy source code into container
COPY . /app

# Build the project (debug build by default)
RUN swift build

# Default command runs tests
CMD ["swift", "test", "-v"]

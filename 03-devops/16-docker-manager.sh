#!/bin/bash

# Script: Docker Container Manager
# Purpose: Manage Docker containers, images, and basic operations
# Usage: ./16-docker-manager.sh [command] [options]

echo "=== Docker Container Manager ==="

# Check if Docker is installed
if ! command -v docker >/dev/null 2>&1; then
    echo "Error: Docker is not installed or not in PATH"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker daemon is not running"
    echo "Please start Docker service"
    exit 1
fi

# Function to display usage
usage() {
    echo "Usage: $0 [command] [options]"
    echo "Commands:"
    echo "  list                      - List all containers"
    echo "  images                    - List all images"
    echo "  run <image> [name]        - Run container from image"
    echo "  stop <container>          - Stop container"
    echo "  start <container>         - Start container"
    echo "  remove <container>        - Remove container"
    echo "  logs <container>          - Show container logs"
    echo "  exec <container> <cmd>    - Execute command in container"
    echo "  stats                     - Show container resource usage"
    echo "  cleanup                   - Clean up unused containers/images"
    echo "  build <dockerfile_dir>    - Build image from Dockerfile"
    exit 1
}

# Function to list containers
list_containers() {
    echo "Docker Containers:"
    echo "=================="
    echo "Running containers:"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
    
    echo
    echo "All containers:"
    docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.CreatedAt}}"
}

# Function to list images
list_images() {
    echo "Docker Images:"
    echo "=============="
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
}

# Function to run container
run_container() {
    local image=$1
    local name=$2
    
    if [ -z "$image" ]; then
        echo "Error: Image name required"
        return 1
    fi
    
    local run_cmd="docker run -d"
    
    if [ -n "$name" ]; then
        run_cmd="$run_cmd --name $name"
    fi
    
    # Add common options based on image type
    case $image in
        *nginx*)
            run_cmd="$run_cmd -p 80:80"
            ;;
        *apache*)
            run_cmd="$run_cmd -p 80:80"
            ;;
        *mysql*)
            run_cmd="$run_cmd -e MYSQL_ROOT_PASSWORD=rootpass"
            ;;
        *postgres*)
            run_cmd="$run_cmd -e POSTGRES_PASSWORD=postgres"
            ;;
    esac
    
    run_cmd="$run_cmd $image"
    
    echo "Running: $run_cmd"
    if $run_cmd; then
        echo "Container started successfully"
        echo "Container ID: $(docker ps -l -q)"
    else
        echo "Failed to start container"
    fi
}

# Function to stop container
stop_container() {
    local container=$1
    if [ -z "$container" ]; then
        echo "Error: Container name or ID required"
        return 1
    fi
    
    echo "Stopping container: $container"
    if docker stop "$container"; then
        echo "Container stopped successfully"
    else
        echo "Failed to stop container"
    fi
}

# Function to start container
start_container() {
    local container=$1
    if [ -z "$container" ]; then
        echo "Error: Container name or ID required"
        return 1
    fi
    
    echo "Starting container: $container"
    if docker start "$container"; then
        echo "Container started successfully"
    else
        echo "Failed to start container"
    fi
}

# Function to remove container
remove_container() {
    local container=$1
    if [ -z "$container" ]; then
        echo "Error: Container name or ID required"
        return 1
    fi
    
    echo "Removing container: $container"
    # Stop container first if running
    docker stop "$container" 2>/dev/null
    
    if docker rm "$container"; then
        echo "Container removed successfully"
    else
        echo "Failed to remove container"
    fi
}

# Function to show container logs
show_logs() {
    local container=$1
    if [ -z "$container" ]; then
        echo "Error: Container name or ID required"
        return 1
    fi
    
    echo "Logs for container: $container"
    echo "=============================="
    docker logs --tail 50 -f "$container"
}

# Function to execute command in container
exec_command() {
    local container=$1
    shift
    local command="$@"
    
    if [ -z "$container" ]; then
        echo "Error: Container name or ID required"
        return 1
    fi
    
    if [ -z "$command" ]; then
        command="/bin/bash"
    fi
    
    echo "Executing in container $container: $command"
    docker exec -it "$container" $command
}

# Function to show container stats
show_stats() {
    echo "Container Resource Usage:"
    echo "========================"
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
}

# Function to cleanup unused resources
cleanup_docker() {
    echo "Docker Cleanup:"
    echo "==============="
    
    echo "Removing stopped containers..."
    docker container prune -f
    
    echo "Removing unused images..."
    docker image prune -f
    
    echo "Removing unused networks..."
    docker network prune -f
    
    echo "Removing unused volumes..."
    docker volume prune -f
    
    echo "Cleanup completed!"
    
    echo
    echo "Disk usage after cleanup:"
    docker system df
}

# Function to build image
build_image() {
    local dockerfile_dir=$1
    if [ -z "$dockerfile_dir" ]; then
        echo "Error: Dockerfile directory required"
        return 1
    fi
    
    if [ ! -f "$dockerfile_dir/Dockerfile" ]; then
        echo "Error: Dockerfile not found in $dockerfile_dir"
        return 1
    fi
    
    local image_name=$(basename "$dockerfile_dir")
    echo "Building image: $image_name from $dockerfile_dir"
    
    if docker build -t "$image_name" "$dockerfile_dir"; then
        echo "Image built successfully: $image_name"
    else
        echo "Failed to build image"
    fi
}

# Function to create sample Dockerfile
create_sample_dockerfile() {
    local dir="sample_docker_app"
    mkdir -p "$dir"
    
    cat > "$dir/Dockerfile" << 'EOF'
# Sample Dockerfile for a simple web application
FROM nginx:alpine

# Copy custom configuration
COPY index.html /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
EOF

    cat > "$dir/index.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Sample Docker App</title>
</head>
<body>
    <h1>Hello from Docker!</h1>
    <p>This is a sample application running in a Docker container.</p>
    <p>Built with Bash script automation!</p>
</body>
</html>
EOF

    echo "Sample Docker application created in: $dir"
    echo "To build: $0 build $dir"
}

# Main script logic
case "${1:-}" in
    "list")
        list_containers
        ;;
    "images")
        list_images
        ;;
    "run")
        if [ -z "$2" ]; then
            echo "Error: Image name required"
            usage
        fi
        run_container "$2" "$3"
        ;;
    "stop")
        if [ -z "$2" ]; then
            echo "Error: Container name or ID required"
            usage
        fi
        stop_container "$2"
        ;;
    "start")
        if [ -z "$2" ]; then
            echo "Error: Container name or ID required"
            usage
        fi
        start_container "$2"
        ;;
    "remove")
        if [ -z "$2" ]; then
            echo "Error: Container name or ID required"
            usage
        fi
        remove_container "$2"
        ;;
    "logs")
        if [ -z "$2" ]; then
            echo "Error: Container name or ID required"
            usage
        fi
        show_logs "$2"
        ;;
    "exec")
        if [ -z "$2" ]; then
            echo "Error: Container name or ID required"
            usage
        fi
        shift 2
        exec_command "$2" "$@"
        ;;
    "stats")
        show_stats
        ;;
    "cleanup")
        cleanup_docker
        ;;
    "build")
        if [ -z "$2" ]; then
            echo "Error: Dockerfile directory required"
            usage
        fi
        build_image "$2"
        ;;
    "sample")
        create_sample_dockerfile
        ;;
    *)
        usage
        ;;
esac

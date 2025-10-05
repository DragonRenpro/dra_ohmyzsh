#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if git is installed
check_git() {
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed. Please install git first."
        exit 1
    fi
    print_success "Git is installed"
}

# Clone or update the repository
setup_ohmyzsh() {
    local ohmyzsh_dir="$HOME/.oh-my-zsh"
    
    if [ -d "$ohmyzsh_dir" ]; then
        print_status "Oh My Zsh directory already exists. Updating..."
        cd "$ohmyzsh_dir"
        git pull origin master
    else
        print_status "Cloning dra_ohmyzsh repository..."
        git clone https://github.com/DragonRenpro/dra_ohmyzsh.git "$ohmyzsh_dir"
    fi
    
    if [ $? -eq 0 ]; then
        print_success "Oh My Zsh setup completed"
    else
        print_error "Failed to setup Oh My Zsh"
        exit 1
    fi
}

# Install required packages
install_packages() {
    print_status "Checking and installing required packages..."
    
    # Function to check and install package
    install_if_missing() {
        local package=$1
        if ! command -v "$package" &> /dev/null; then
            print_status "Installing $package..."
            
            # Detect package manager
            if command -v apt-get &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y "$package"
            elif command -v yum &> /dev/null; then
                sudo yum install -y "$package"
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y "$package"
            elif command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm "$package"
            elif command -v brew &> /dev/null; then
                brew install "$package"
            else
                print_error "Unsupported package manager. Please install $package manually."
                return 1
            fi
        else
            print_success "$package is already installed"
        fi
    }
    
    # Install required packages
    install_if_missing zsh
    install_if_missing fzf
    install_if_missing tmux
}

# Setup zsh configuration
setup_zsh_config() {
    local zshrc_source="$HOME/.oh-my-zsh/.zshrc"
    local zshrc_dest="$HOME/.zshrc"
    
    print_status "Setting up zsh configuration..."
    
    if [ -f "$zshrc_dest" ]; then
        print_warning "Existing .zshrc found. Creating backup..."
        cp "$zshrc_dest" "$zshrc_dest.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    cp "$zshrc_source" "$zshrc_dest"
    print_success "Zsh configuration copied"
}

# Set zsh as default shell
set_default_shell() {
    print_status "Setting zsh as default shell..."
    
    local current_shell=$(basename "$SHELL")
    if [ "$current_shell" != "zsh" ]; then
        if command -v chsh &> /dev/null; then
            chsh -s $(which zsh)
            print_success "Default shell changed to zsh. Please log out and log back in for changes to take effect."
        else
            print_warning "chsh command not found. Please set zsh as default shell manually."
        fi
    else
        print_success "Zsh is already the default shell"
    fi
}

# Main installation function
main() {
    print_status "Starting DragonRen's Oh My Zsh installation..."
    
    # Check dependencies
    check_git
    
    # Setup Oh My Zsh
    setup_ohmyzsh
    
    # Install required packages
    install_packages
    
    # Setup configuration
    setup_zsh_config
    
    # Set default shell
    set_default_shell
    
    print_success "Installation completed successfully!"
    echo ""
    print_status "Next steps:"
    echo "  1. Log out and log back in to use zsh"
    echo "  2. Open a new terminal to see your new setup"
    echo "  3. Run 'tmux' to start tmux session"
    echo "  4. Use Ctrl+R for fzf history search"
}

# Run main function
main "$@"


import os
import sys
import toml
import logging
import argparse
from logging.config import dictConfig
from typing import Any, Dict

# Custom exception for configuration errors
class ConfigurationError(Exception):
    pass

# Utility function to load configuration from a TOML file
def load_config(config_file: str) -> Dict[str, Any]:
    try:
        with open(config_file, 'r') as file:
            config = toml.load(file)
            return config
    except FileNotFoundError:
        raise ConfigurationError(f"Configuration file '{config_file}' not found.")
    except toml.TomlDecodeError as e:
        raise ConfigurationError(f"Error parsing configuration file: {e}")

# Function to set up logging
def setup_logging(log_level: str):
    logging_config = {
        'version': 1,
        'disable_existing_loggers': False,
        'formatters': {
            'default': {
                'format': '[%(asctime)s] %(levelname)s in %(module)s: %(message)s',
            },
        },
        'handlers': {
            'console': {
                'class': 'logging.StreamHandler',
                'formatter': 'default',
            },
        },
        'root': {
            'level': log_level,
            'handlers': ['console']
        },
    }
    dictConfig(logging_config)

# Main application class
class MyApp:
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.logger = logging.getLogger(self.__class__.__name__)
        self.data_file = config['settings']['data_file']
        self.max_retries = config['settings']['max_retries']
        self.database_config = config['database']

    def run(self):
        self.logger.info("Starting the application...")
        self.logger.debug(f"Configuration: {self.config}")
        
        # Dummy database connection demonstration
        self.connect_to_database()

        # Example operation with retry logic
        self.perform_operation_with_retries()

    def connect_to_database(self):
        db_config = self.database_config

        self.logger.info(f"Connecting to database at {db_config['host']}:{db_config['port']}...")
        
        self.logger.debug(f"Using credentials: {db_config['username']}/{db_config['password']}")

    def perform_operation_with_retries(self):
        for attempt in range(1, self.max_retries + 1):
            try:
                self.logger.info(f"Performing operation (Attempt {attempt}/{self.max_retries})...")
                
                if attempt < self.max_retries:
                    raise RuntimeError("Dummy error for demonstration purposes.")
                self.logger.info("Operation completed successfully.")
                break
            except Exception as e:
                self.logger.error(f"Error during operation: {e}")
                if attempt == self.max_retries:
                    self.logger.critical("Maximum retry limit reached. Operation failed.")
                    sys.exit(1)

# Argument parsing
def parse_args():
    parser = argparse.ArgumentParser(description="Run My Advanced App.")
    parser.add_argument('--config', type=str, default='config.toml', help='Path to the configuration file.')
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()

    # Load configuration
    config = load_config(args.config)

    # Set up logging
    setup_logging(config['settings']['log_level'])

    # Create and run the application
    app = MyApp(config)
    app.run()

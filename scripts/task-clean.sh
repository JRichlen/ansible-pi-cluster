#!/bin/bash

echo "🧹 Cleaning up temporary files..."
find . -name "*.retry" -delete 2>/dev/null || true
find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
echo "✔ Cleanup completed"

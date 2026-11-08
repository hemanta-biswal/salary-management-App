import uvicorn
import os
import sys

if __name__ == "__main__":
    current_dir = os.path.dirname(os.path.abspath(__file__))
    sys.path.append(current_dir)
    print("=" * 55)
    print("SalaryPro Backend Server starting on http://localhost:8000")
    print("Interactive Swagger API Docs at: http://localhost:8000/docs")
    print("=" * 55)
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)


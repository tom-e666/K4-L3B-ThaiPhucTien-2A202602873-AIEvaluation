py -m venv .venv
.venv\Scripts\Activate.ps1

python -m pip install -r requirements.txt
    python -c "import openai, dotenv, pytest; print('Environment OK')"
pytest tests/ -v
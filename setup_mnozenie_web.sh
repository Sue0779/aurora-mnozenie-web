#!/usr/bin/env bash
set -e

APP_DIR="$HOME/AuroraMnozenieWeb"
IMAGE_NAME="aurora-mnozenie-web"
CONTAINER_NAME="aurora-mnozenie-web"
PORT="8000"

echo "[*] Przygotowanie katalogu..."
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/templates" "$APP_DIR/static"

# ===== app.py =====
cat > "$APP_DIR/app.py" << 'PYEOF'
#!/usr/bin/env python3
import random
from flask import Flask, render_template, request, jsonify

app = Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/api/next")
def api_next():
    a = random.randint(1, 10)
    b = random.randint(1, 10)
    return jsonify({"a": a, "b": b})

@app.route("/api/check", methods=["POST"])
def api_check():
    data = request.get_json(force=True)
    a = int(data.get("a", 0))
    b = int(data.get("b", 0))
    ans = data.get("ans", "").strip()
    correct = a * b
    try:
        user = int(ans)
    except ValueError:
        return jsonify({"ok": False, "correct": correct, "msg": "To nie jest liczba."})
    if user == correct:
        return jsonify({"ok": True, "correct": correct, "msg": "Brawo, dobrze!"})
    else:
        return jsonify({"ok": False, "correct": correct, "msg": "Nie, spróbuj dalej."})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
PYEOF

# ===== templates/index.html =====
cat > "$APP_DIR/templates/index.html" << 'HTEOF'
<!DOCTYPE html>
<html lang="pl">
<head>
  <meta charset="UTF-8">
  <title>Aurora Mnożenie</title>
  <link rel="stylesheet" href="/static/style.css">
</head>
<body>
<div class="page">
  <div class="title">Aurora Mnożenie</div>
  <div class="card">
    <div class="mascot">✿</div>
    <div id="task" class="task">Kliknij START</div>
    <div class="input-row">
      <input id="answer" type="number" placeholder="Twój wynik">
      <button id="checkBtn">OK</button>
    </div>
    <div id="msg" class="msg"></div>
    <button id="nextBtn" class="next">START</button>
  </div>
  <div class="footer">Kolorowa tabliczka mnożenia · bez reklam</div>
</div>
<script>
let a,b;
async function nextTask(){const r=await fetch("/api/next");const d=await r.json();a=d.a;b=d.b;
document.getElementById("task").textContent=a+" × "+b+" = ?";document.getElementById("answer").value="";}
async function check(){const ans=document.getElementById("answer").value;
const r=await fetch("/api/check",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({a:a,b:b,ans:ans})});
const d=await r.json();const m=document.getElementById("msg");m.textContent=d.msg+(d.ok?" ✔":" ✗ (="+d.correct+")");
m.className="msg "+(d.ok?"ok":"bad");if(d.ok)setTimeout(nextTask,500);}
document.getElementById("nextBtn").onclick=nextTask;
document.getElementById("checkBtn").onclick=check;
document.getElementById("answer").addEventListener("keydown",e=>{if(e.key==="Enter")check();});
</script>
</body>
</html>
HTEOF

# ===== static/style.css =====
cat > "$APP_DIR/static/style.css" << 'CSEOF'
body {
  background: linear-gradient(180deg, #fffdf5, #ffe4f0);
  font-family: system-ui, sans-serif;
  margin: 0;
}
.page {
  display: flex; flex-direction: column; align-items: center;
  justify-content: center; min-height: 100vh;
}
.title { font-size: 32px; font-weight: 700; color: #e74c3c; margin-bottom: 16px; }
.card {
  background: #fff; border-radius: 24px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);
  padding: 20px; width: 300px; text-align: center;
}
.task { font-size: 22px; margin: 10px 0; }
.input-row { display: flex; gap: 6px; }
.input-row input {
  flex: 1; padding: 8px; font-size: 16px; text-align: center;
  border-radius: 10px; border: 2px solid #ffd1dc;
}
.input-row button {
  padding: 8px 10px; border: none; border-radius: 10px;
  background: #ff6b81; color: #fff; font-weight: bold; cursor: pointer;
}
.msg { min-height: 20px; margin: 8px 0; }
.msg.ok { color: #2ecc71; }
.msg.bad { color: #e74c3c; }
.next {
  margin-top: 4px; width: 100%; padding: 8px; border: none; border-radius: 10px;
  background: #ffd26f; color: #663300; font-weight: bold;
}
.footer { font-size: 11px; color: #888; margin-top: 12px; }
CSEOF

# ===== Dockerfile =====
cat > "$APP_DIR/Dockerfile" << 'DOCKEOF'
FROM python:3.12-slim
WORKDIR /app
RUN pip install --no-cache-dir flask
COPY app.py templates static ./
EXPOSE 8000
CMD ["python","app.py"]
DOCKEOF

echo "[*] Buduję obraz Dockera..."
cd "$APP_DIR"
docker build -t "$IMAGE_NAME" .
docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
docker run -d --name "$CONTAINER_NAME" -p "$PORT:8000" "$IMAGE_NAME" >/dev/null
echo "[*] Gotowe! Otwórz w przeglądarce: http://127.0.0.1:$PORT/"

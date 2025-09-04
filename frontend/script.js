// Minimal client-side calls to the Ballerina backend under same origin
async function predictSample() {
  const payload = { rainMm: 12.3, windKph: 10, tempC: 29, humidityPct: 70, soilSatPct: 50 };
  const res = await fetch('/ai/predict', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) });
  return await res.json();
}

window.addEventListener('DOMContentLoaded', () => {
  const btn = document.getElementById('activate-button');
  if (!btn) return;
  btn.addEventListener('click', async (e) => {
    e.preventDefault();
    try {
      const resp = await predictSample();
      alert('Risk: ' + (resp.riskScore ?? 'n/a'));
    } catch (e) { console.error(e); }
  });
});


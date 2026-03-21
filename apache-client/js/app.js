const config = globalThis.__APP_CONFIG || {};
const apiBaseUrl = (config.apiBaseUrl || "https://api.tudominio.com").replace(/\/$/, "");

const state = {
  token: null
};

const outputEl = document.getElementById("output");
const apiStatusEl = document.getElementById("apiStatus");

const registerForm = document.getElementById("registerForm");
const loginForm = document.getElementById("loginForm");
const btnMe = document.getElementById("btnMe");
const btnLogout = document.getElementById("btnLogout");

function printResult(data) {
  outputEl.textContent = JSON.stringify(data, null, 2);
}

function printError(error) {
  outputEl.textContent = typeof error === "string" ? error : JSON.stringify(error, null, 2);
}

async function apiCall(path, options = {}) {
  const headers = {
    "Content-Type": "application/json"
  };

  if (options.headers) {
    Object.assign(headers, options.headers);
  }

  if (state.token) {
    headers.Authorization = `Bearer ${state.token}`;
  }

  const response = await fetch(`${apiBaseUrl}${path}`, {
    ...options,
    headers
  });

  const isJson = response.headers.get("content-type")?.includes("application/json");
  const payload = isJson ? await response.json() : await response.text();

  if (!response.ok) {
    throw payload;
  }

  return payload;
}

async function checkApiStatus() {
  try {
    await apiCall("/api/public/health", { method: "GET" });
    apiStatusEl.textContent = "API status: secure endpoint reachable";
    apiStatusEl.style.color = "#95ffba";
  } catch (error) {
    apiStatusEl.textContent = "API status: unavailable";
    apiStatusEl.style.color = "#ffb2b2";
    printError(error);
  }
}

registerForm.addEventListener("submit", async (event) => {
  event.preventDefault();
  const email = document.getElementById("registerEmail").value;
  const password = document.getElementById("registerPassword").value;

  try {
    const result = await apiCall("/api/auth/register", {
      method: "POST",
      body: JSON.stringify({ email, password })
    });
    state.token = result.token;
    printResult({ message: "Registration successful", result });
  } catch (error) {
    printError({ message: "Registration failed", error });
  }
});

loginForm.addEventListener("submit", async (event) => {
  event.preventDefault();
  const email = document.getElementById("loginEmail").value;
  const password = document.getElementById("loginPassword").value;

  try {
    const result = await apiCall("/api/auth/login", {
      method: "POST",
      body: JSON.stringify({ email, password })
    });
    state.token = result.token;
    printResult({ message: "Login successful", result });
  } catch (error) {
    printError({ message: "Invalid credentials", error });
  }
});

btnMe.addEventListener("click", async () => {
  try {
    const me = await apiCall("/api/secure/me", { method: "GET" });
    printResult({ message: "Secure profile", me });
  } catch (error) {
    printError({ message: "Unauthorized", error });
  }
});

btnLogout.addEventListener("click", () => {
  state.token = null;
  printResult({ message: "Signed out" });
});

await checkApiStatus();

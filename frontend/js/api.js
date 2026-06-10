const API_BASE = "http://localhost:3000";

async function createAwsAccount(data) {

  const response = await fetch(
    `${API_BASE}/aws-accounts`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(data)
    }
  );

  return response.json();
}

async function createInstance(data) {

  const response = await fetch(
    `${API_BASE}/instances`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(data)
    }
  );

  return response.json();
}

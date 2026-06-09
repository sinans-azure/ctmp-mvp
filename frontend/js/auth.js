function login(role) {

  if(role === "admin"){
    window.location.href = "/admin/dashboard.html";
  }

  if(role === "trainer"){
    window.location.href = "/trainer/dashboard.html";
  }

  if(role === "student"){
    window.location.href = "/student/dashboard.html";
  }
}
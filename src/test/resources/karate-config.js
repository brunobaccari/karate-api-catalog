function fn() {
  karate.configure('connectTimeout', 10000);
  karate.configure('readTimeout', 15000);
  return { baseUrl: karate.properties['api.baseUrl'] };
}

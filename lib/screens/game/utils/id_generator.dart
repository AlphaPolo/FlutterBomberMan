typedef IdGenerator = int Function();

IdGenerator idGenerator() {
  int id = 0;
  return () => id++;
}
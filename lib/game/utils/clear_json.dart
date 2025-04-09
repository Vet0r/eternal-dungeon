String cleanJson(String response) {
  return response
      .replaceAllMapped(RegExp(r'```json|```'), (match) => '')
      .trim();
}

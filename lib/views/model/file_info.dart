class FileInfo {
  final String name;
  final String date;
  final String size;

  FileInfo(this.name, this.date, this.size);

  factory FileInfo.fromString(String fileString) {
    // Patrón de expresión regular:
    // - Nombre del archivo hasta antes de la fecha
    // - Fecha con formato dd/MM/yyyy
    // - Tamaño con número + unidad (ej: 6,22 MB)
    final regex = RegExp(r'^(.+?)\s+(\d{2}/\d{2}/\d{4})\s+([\d,.]+\s+[A-Z]{2})$');

    final match = regex.firstMatch(fileString.trim());

    if (match != null && match.groupCount == 3) {
      final name = match.group(1)?.trim() ?? '';
      final date = match.group(2)?.trim() ?? '';
      final size = match.group(3)?.trim() ?? '';
      return FileInfo(name, date, size);
    }

    // Si no coincide, devolver como solo nombre
    return FileInfo(fileString, '', '');
  }
}
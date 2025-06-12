import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:xmltxt2/views/model/file_info.dart';
import 'package:xmltxt2/views/model/list_dir_response.dart';
import 'package:xmltxt2/views/model/list_process_response.dart';
import 'package:xmltxt2/views/service/xml_service.dart';

import 'core/constant/constant.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config=await ConfigLoader.loadConfig();
  //print(config['api_url']);
  AppStrings.urlApi=config['api_url'];
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SIGECOF - SENIAT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0061A4)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home:  SENIATUploadView(),
    );
  }
}



class SeniatController extends GetxController {
  // Estados
  var xmlFiles = <FileInfo>[].obs; // Ahora contiene FileInfo directamente
  var resultados = <Map<String, dynamic>>[].obs;
  var totalPlanillas = 0.obs;
  var totalErrores = 0.obs;
  var isLoading = false.obs;
  var isProcessing = false.obs;

  Future<void> consultarArchivos() async {
    isLoading.value = true;
    xmlFiles.clear();
    resultados.clear();

    //await Future.delayed(const Duration(seconds: 2));
    final apiResponse = await XmlService.get('api/xmltxt/list');
    if (apiResponse == null || apiResponse.isEmpty) {
      Get.snackbar('Información', 'No se encontraron archivos');
      xmlFiles.clear();
      isLoading.value = false;
      return;
    }
    final res = ListDir.fromJson(apiResponse);
    if (res.res == null || res.res!.files == null || res.res!.files!.isEmpty) {
      Get.snackbar('Información', 'No hay archivos disponibles');
      xmlFiles.clear();
      isLoading.value = false;
      return;
    }

    final processedFiles = res.res!.files!.map((str) {
      final fileInfo = FileInfo.fromString(str);
      debugPrint('Procesado: ${fileInfo.name} | ${fileInfo.date} | ${fileInfo.size}');
      return fileInfo;
    }).toList();

    xmlFiles.assignAll(processedFiles);
    isLoading.value = false;
  }

  Future<void> procesarArchivos() async {
    if (xmlFiles.isEmpty) {
      Get.snackbar("Advertencia", "No hay archivos para procesar.");
      return;
    }

    isProcessing.value = true;

    try {
      final apiResponse = await XmlService.get('api/xmltxt/process');

      if (apiResponse == null || apiResponse.isEmpty) {
        Get.snackbar('Error', 'No se recibió respuesta del servidor');
        return;
      }

      final res = ListProcess.fromJson(apiResponse);

      // ✅ Convertimos los objetos Resultados a Map<String, dynamic>
      if (res.resultados != null && res.resultados!.isNotEmpty) {
        final List<Map<String, dynamic>> mappedResults = res.resultados!
            .map((resultado) => resultado.toJson())
            .toList();

        resultados.assignAll(mappedResults);
      } else {
        Get.snackbar("Información", "No se encontraron resultados");
      }

      totalPlanillas.value = res.totalPlanillas ?? 0;
      totalErrores.value = res.totalErrores ?? 0;

      Get.snackbar("Éxito", "Se procesaron ${resultados.length} archivos.");
    } catch (e) {
      Get.snackbar("Error", "Ocurrió un error al procesar: $e");
      debugPrint("Error al procesar archivos: $e");
    } finally {
      isProcessing.value = false;
    }
  }
}





class SENIATUploadView extends StatelessWidget {
  SENIATUploadView({super.key});

  final SeniatController controller = Get.put(SeniatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Botones
              _buildActionButtons(),
              const SizedBox(height: 32),

              // Contenido
              Expanded(
                child: _buildContent(),
              ),

              // Totales (solo se muestra después de procesar)
              if (controller.resultados.isNotEmpty) _buildTotalsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SIGECOF - SENIAT',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Procesamiento de archivos XML',
          style: TextStyle(
            fontSize: 16,
            color: Colors.blue.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Obx(() {
      final ctrl = controller;
      return Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton(
            onPressed: ctrl.isLoading.value ? null : ctrl.consultarArchivos,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade800,
              padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (ctrl.isLoading.value)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.blue,
                      ),
                    ),
                  )
                else
                  const Icon(Icons.search, size: 24),
                const SizedBox(width: 8),
                Text(
                  ctrl.isLoading.value ? 'Buscando...' : 'Consultar XML',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: ctrl.xmlFiles.isEmpty || ctrl.isProcessing.value
                ? null
                : ctrl.procesarArchivos,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade50,
              foregroundColor: Colors.green.shade800,
              padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.isProcessing.value)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.green,
                      ),
                    ),
                  )
                else
                  const Icon(Icons.cloud_upload, size: 24),
                const SizedBox(width: 8),
                Text(
                  controller.isProcessing.value
                      ? 'Procesando...'
                      : 'Procesar Archivos',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingIndicator();
      } else if (controller.xmlFiles.isNotEmpty && controller.resultados.isEmpty) {
        return _buildFilesList();
      } else if (controller.resultados.isNotEmpty) {
        return _buildResultsList();
      } else {
        return _buildEmptyState();
      }
    });
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor:
              AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Cargando información...',
            style: TextStyle(
              fontSize: 18,
              color: Colors.blue.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: Colors.blue.shade200,
          ),
          const SizedBox(height: 20),
          Text(
            'No hay archivos disponibles',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Presiona el botón "Consultar XML" para buscar archivos SENIAT en el servidor',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesList() {
    return Obx(() {
      final ctrl = controller;
      return Column(
        children: [
          Text(
            'Archivos encontrados: ${ctrl.xmlFiles.length}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: ctrl.xmlFiles.length,
                  separatorBuilder: (_, __) => const Divider(height: 16),
                  itemBuilder: (_, index) {
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child:  Icon(
                          Icons.insert_drive_file,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      title: Text(
                        ctrl.xmlFiles[index].name,
                        style: TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Fecha: ',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            TextSpan(
                              text: ctrl.xmlFiles[index].date,
                              style: TextStyle(color: Colors.black54),
                            ),
                            TextSpan(text: '  •  '),
                            TextSpan(
                              text: 'Tamaño: ',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            TextSpan(
                              text: ctrl.xmlFiles[index].size,
                              style: TextStyle(
                                color: Colors.teal[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: (){

                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildResultsList() {
    return Obx(() {
      final ctrl = controller;
      return Column(
        children: [
          Text(
            'Resultados del procesamiento',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: ctrl.resultados.length,
                  separatorBuilder: (_, __) => const Divider(height: 16),
                  itemBuilder: (_, index) {
                    final item = ctrl.resultados[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (item['errores'] as int) > 0
                                ? Colors.red.shade50
                                : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            (item['errores'] as int) > 0
                                ? Icons.warning
                                : Icons.check_circle,
                            color: (item['errores'] as int) > 0
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                          ),
                        ),
                        title: Text(
                          item['archivo'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              _buildResultChip(
                                '${item['planillas']} planillas',
                                Colors.green.shade600,
                              ),
                              const SizedBox(width: 10),
                              _buildResultChip(
                                '${item['errores']} errores',
                                (item['errores'] as int) > 0 ? Colors.red.shade600 : Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildResultChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTotalsCard() {
    return Obx(() {
      final ctrl = controller;
      return Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade700,
              Colors.blue.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTotalItem(
              'Total Planillas',
              ctrl.totalPlanillas.toString(),
              Icons.list_alt,
              Colors.white,
            ),
            Container(
              width: 1,
              height: 50,
              color: Colors.white.withOpacity(0.3),
            ),
            _buildTotalItem(
              'Total Errores',
              ctrl.totalErrores.toString(),
              Icons.warning,
              ctrl.totalErrores.value > 0
                  ? Colors.orange.shade200
                  : Colors.white,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTotalItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
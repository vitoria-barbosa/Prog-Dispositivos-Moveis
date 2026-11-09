import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps - Marcadores',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const MapaPage(),
    );
  }
}

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  final Completer<GoogleMapController> _controller = Completer();

  Set<Marker> _marcadores = {};
  int _contadorMarcadores = 0;

  Position? _posicaoAtual;

  static const CameraPosition _posicaoInicial = CameraPosition(
    target: LatLng(-5.088544046019581, -42.81123803149089),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    _carregarMarcadores();
    _localizacaoAtual();
  }

  void _carregarMarcadores() {
    final Set<Marker> marcadoresLocal = {};

    final marcadorIfpi = Marker(
      markerId: const MarkerId('IFPI'),
      position: const LatLng(-5.088544046019581, -42.81123803149089),
      infoWindow: const InfoWindow(title: 'IFPI - Campus Teresina Central'),
    );
    final marcadorIfpiSul = Marker(
      markerId: const MarkerId('IFPI_SUL'),
      position: const LatLng(-5.101723, -42.813114),
      infoWindow: const InfoWindow(title: 'IFPI - Campus Teresina Sul'),
    );

    marcadoresLocal.add(marcadorIfpi);
    marcadoresLocal.add(marcadorIfpiSul);

    setState(() {
      _marcadores = marcadoresLocal;
    });
  }

  Future<void> _localizacaoAtual() async {
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      _mostrarMensagem('Ative o serviço de localização do dispositivo.');
      return;
    }

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.denied ||
        permissao == LocationPermission.deniedForever) {
      _mostrarMensagem('Permissão de localização negada.');
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    debugPrint('Localização: $position');

    if (!mounted) return;
    setState(() => _posicaoAtual = position);
    _moverCamera(LatLng(position.latitude, position.longitude));
  }

  Future<void> _moverCamera(LatLng destino, {double zoom = 15}) async {
    final controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: destino, zoom: zoom),
      ),
    );
  }

  void _adicionarMarcador(String label, LatLng posicao) {
    _contadorMarcadores++;
    final id = MarkerId('usuario_$_contadorMarcadores');

    final marcador = Marker(
      markerId: id,
      position: posicao,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: InfoWindow(
        title: label,
        snippet:
            '${posicao.latitude.toStringAsFixed(6)}, ${posicao.longitude.toStringAsFixed(6)}',
      ),
    );

    setState(() {
      _marcadores = {..._marcadores, marcador};
    });

    _moverCamera(posicao).then((_) async {
      final controller = await _controller.future;
      controller.showMarkerInfoWindow(id);
    });
  }

  void _limparMarcadoresUsuario() {
    setState(() {
      _marcadores = _marcadores
          .where((m) => !m.markerId.value.startsWith('usuario_'))
          .toSet();
    });
    _mostrarMensagem('Marcadores adicionados foram removidos.');
  }

  void _mostrarMensagem(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _abrirFormulario({LatLng? posicaoSugerida}) async {
    final resultado = await showModalBottomSheet<_NovoMarcador>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FormularioMarcador(
        posicaoSugerida: posicaoSugerida,
        posicaoAtual: _posicaoAtual,
      ),
    );

    if (resultado != null) {
      _adicionarMarcador(resultado.label, resultado.posicao);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usando Google Maps'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            tooltip: 'Minha localização',
            icon: const Icon(Icons.my_location),
            onPressed: _localizacaoAtual,
          ),
          IconButton(
            tooltip: 'Remover marcadores adicionados',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _limparMarcadoresUsuario,
          ),
        ],
      ),
      body: GoogleMap(
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        mapType: MapType.normal,
        initialCameraPosition: _posicaoInicial,
        onMapCreated: (GoogleMapController controller) {
          if (!_controller.isCompleted) _controller.complete(controller);
        },
        markers: _marcadores,
        // Pressionar e segurar no mapa já preenche latitude/longitude
        onLongPress: (posicao) => _abrirFormulario(posicaoSugerida: posicao),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormulario,
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Adicionar marcador'),
      ),
    );
  }
}

class _NovoMarcador {
  final String label;
  final LatLng posicao;
  const _NovoMarcador(this.label, this.posicao);
}

class _FormularioMarcador extends StatefulWidget {
  final LatLng? posicaoSugerida;
  final Position? posicaoAtual;

  const _FormularioMarcador({this.posicaoSugerida, this.posicaoAtual});

  @override
  State<_FormularioMarcador> createState() => _FormularioMarcadorState();
}

class _FormularioMarcadorState extends State<_FormularioMarcador> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final sugerida = widget.posicaoSugerida;
    if (sugerida != null) {
      _preencher(sugerida.latitude, sugerida.longitude);
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _preencher(double lat, double lng) {
    _latController.text = lat.toStringAsFixed(6);
    _lngController.text = lng.toStringAsFixed(6);
  }

  // Aceita tanto ponto quanto vírgula como separador decimal
  double? _converter(String? valor) =>
      double.tryParse((valor ?? '').trim().replaceAll(',', '.'));

  String? _validarCoordenada(String? valor, double limite, String nome) {
    final numero = _converter(valor);
    if (numero == null) return 'Informe a $nome';
    if (numero < -limite || numero > limite) {
      return '$nome deve estar entre -$limite e $limite';
    }
    return null;
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      _NovoMarcador(
        _labelController.text.trim(),
        LatLng(
          _converter(_latController.text)!,
          _converter(_lngController.text)!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const teclado = TextInputType.numberWithOptions(
      signed: true,
      decimal: true,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Novo marcador',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _labelController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Label (nome do local)',
                prefixIcon: Icon(Icons.label_outline),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe um label' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latController,
                    keyboardType: teclado,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      hintText: '-5.088544',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => _validarCoordenada(v, 90, 'latitude'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lngController,
                    keyboardType: teclado,
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      hintText: '-42.811238',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => _validarCoordenada(v, 180, 'longitude'),
                  ),
                ),
              ],
            ),
            if (widget.posicaoAtual != null) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.gps_fixed, size: 18),
                  label: const Text('Usar minha localização atual'),
                  onPressed: () => setState(
                    () => _preencher(
                      widget.posicaoAtual!.latitude,
                      widget.posicaoAtual!.longitude,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _salvar,
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Adicionar no mapa'),
            ),
          ],
        ),
      ),
    );
  }
}

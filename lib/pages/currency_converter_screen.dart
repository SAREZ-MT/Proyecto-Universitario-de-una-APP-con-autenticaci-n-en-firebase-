import 'package:flutter/material.dart';
import '../components/profile_drawer.dart';

//! PANTALLA DE CONVERTIDOR DE DIVISAS
//! Esta clase implementa la funcionalidad principal de la aplicación
//! Permite convertir montos entre diferentes divisas con tasas de cambio predefinidas

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CurrencyConverterScreenState createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  //! Variables de estado para la conversión
  String _fromCurrency = 'USD';    //* Moneda de origen (por defecto USD)
  String _toCurrency = 'EUR';      //* Moneda de destino (por defecto EUR)
  
  //! Controlador para el campo de texto
  final TextEditingController _amountController = TextEditingController();
  
  //! Resultado de la conversión (actualizado por setState)
  double _convertedAmount = 0.0;

  //! Tasas de cambio predefinidas con USD como base
  //* Para una app real, estas tasas deberían obtenerse de una API
  final Map<String, double> _exchangeRates = {
    'USD': 1.0,           //* Dólar estadounidense (base)
    'EUR': 0.92,          //* Euro
    'GBP': 0.77,          //* Libra esterlina
    'JPY': 148.31,        //* Yen japonés
    'MXN': 20.17,         //* Peso mexicano
    'COL': 4133.50,       //* Peso colombiano
  };

  //! Método para realizar la conversión de divisas
  void _convertCurrency() {
    //! Paso 1: Obtener el monto ingresado (o 0 si no es válido)
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    
    //! Paso 2: Obtener las tasas de cambio correspondientes
    double fromRate = _exchangeRates[_fromCurrency] ?? 1.0;  //* Tasa de origen
    double toRate = _exchangeRates[_toCurrency] ?? 1.0;      //* Tasa de destino

    //! Paso 3: Actualizar el estado con el nuevo valor calculado
    setState(() {
      //! Fórmula: monto * (tasa destino / tasa origen)
      _convertedAmount = amount * (toRate / fromRate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //! Barra superior con título y menú
      drawer: ProfileDrawer(), // Menú lateral con información de perfil
      appBar: AppBar(
        title: Text('💱 Convertidor de Divisas'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            //! Campo para ingresar el monto a convertir
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,  //* Teclado numérico
              decoration: InputDecoration(
                labelText: 'Monto a convertir',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.money),
              ),
            ),

            SizedBox(height: 20),

            //! Selector de monedas (origen y destino)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //! Selector de moneda de origen
                _buildCurrencyDropdown(_fromCurrency, (value) {
                  setState(() => _fromCurrency = value!);
                  _convertCurrency();  //* Convertir automáticamente al cambiar
                }, 'De'),

                //! Ícono de flecha entre selectores
                Icon(Icons.compare_arrows, size: 30),

                //! Selector de moneda de destino
                _buildCurrencyDropdown(_toCurrency, (value) {
                  setState(() => _toCurrency = value!);
                  _convertCurrency();  //* Convertir automáticamente al cambiar
                }, 'A'),
              ],
            ),

            SizedBox(height: 30),

            //! Botón para realizar la conversión
            ElevatedButton(
              onPressed: _convertCurrency,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text('Convertir', style: TextStyle(fontSize: 18)),
            ),

            SizedBox(height: 30),

            //! Resultado de la conversión
            //* Formateado a 2 decimales para mejor visualización
            Text(
              'Resultado: ${_convertedAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  //! Widget reutilizable para los selectores de moneda
  //! Construye un DropdownButton personalizado con todas las monedas disponibles
  Widget _buildCurrencyDropdown(String value, Function(String?) onChanged, String hint) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint),
        //! Generar opciones a partir de las monedas disponibles en _exchangeRates
        items: _exchangeRates.keys.map((currency) {
          return DropdownMenuItem<String>(
            value: currency,
            child: Text(currency, style: TextStyle(fontSize: 18)),
          );
        }).toList(),
        onChanged: onChanged,
        underline: Container(),  //* Eliminar línea inferior por defecto
      ),
    );
  }
} 
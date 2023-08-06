import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(const MaterialApp(
    home: CurrencyConverterPage(),
  ));
}

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({Key? key}) : super(key: key);

  @override
  CurrencyConverterPageState createState() => CurrencyConverterPageState();
}

class CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _amountController = TextEditingController();
  double _result = 0;
  bool _isLoading = false;

  final Map<String, String> _currencies = {
    'EUR': 'Euro',
    'USD': 'US Dollar',
    'TRY': 'Turkish Lira',
    'GBP': 'British Pound',
  };

  final Map<String, String> _currencySymbols = {
    'EUR': '€',
    'USD': '\$',
    'TRY': '₺',
    'GBP': '£',
  };

  late String _favoriteCurrency = '';
  late bool _isFavorite = false;

  String _selectedSourceCurrency = 'EUR';
  String _selectedDestinationCurrency = 'TRY';

  @override
  void initState() {
    super.initState();
    _loadFavoriteCurrency();
  }

  void _loadFavoriteCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedFavoriteCurrency = prefs.getString('favoriteCurrency');
    String favoriteCurrency = savedFavoriteCurrency ?? 'TRY';

    setState(() {
      _favoriteCurrency = favoriteCurrency;
      _isFavorite = _favoriteCurrency.isNotEmpty;

      if (_favoriteCurrency.isNotEmpty &&
          _currencies.containsKey(_favoriteCurrency)) {
        _selectedDestinationCurrency = _favoriteCurrency;
        if (_favoriteCurrency == _selectedSourceCurrency) {
          _selectedSourceCurrency =
              _currencies.keys.firstWhere((key) => key != _favoriteCurrency);
        }
      }
    });
  }

  void _convertCurrency() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer un montant.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);

      final url = Uri.parse(
          "https://open.er-api.com/v6/latest/$_selectedSourceCurrency");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final double rate = data["rates"][_selectedDestinationCurrency];

        setState(() {
          _result = amount * rate;
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Conversion échouée. Veuillez réessayer."),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleFavoriteCurrency(String currencyCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      if (_favoriteCurrency == currencyCode) {
        _isFavorite = false;
        _favoriteCurrency = '';
        prefs.remove('favoriteCurrency');
      } else {
        _isFavorite = true;
        _favoriteCurrency = currencyCode;
        prefs.setString('favoriteCurrency', currencyCode);
      }

      if (_selectedDestinationCurrency == currencyCode) {
        _isFavorite = true;
      }
    });
  }

  void _updateDestinationCurrency() {
    if (_selectedDestinationCurrency == _selectedSourceCurrency) {
      _selectedDestinationCurrency = _currencies.keys.firstWhere(
        (currency) =>
            currency != _selectedSourceCurrency &&
            currency != _favoriteCurrency,
        orElse: () => _currencies.keys
            .firstWhere((currency) => currency != _selectedSourceCurrency),
      );

      _isFavorite = false;

      _result = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText:
                          'Entrez le montant en ${_currencies[_selectedSourceCurrency]}',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${NumberFormat("#,##0.00", "fr").format(_result)} ${_currencySymbols[_selectedDestinationCurrency]}',
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  value: _selectedSourceCurrency,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSourceCurrency = newValue!;
                      _updateDestinationCurrency();
                    });
                  },
                  items: _currencies.keys
                      .map<DropdownMenuItem<String>>((String currencyCode) {
                    return DropdownMenuItem<String>(
                      value: currencyCode,
                      child: Text(_currencies[currencyCode]!),
                    );
                  }).toList(),
                ),
                const Icon(Icons.arrow_forward),
                DropdownButton<String>(
                  value: _selectedDestinationCurrency,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedDestinationCurrency = newValue!;
                      _isFavorite =
                          _favoriteCurrency == _selectedDestinationCurrency;
                    });
                  },
                  items: _currencies.keys
                      .where((currency) => currency != _selectedSourceCurrency)
                      .map<DropdownMenuItem<String>>((String currencyCode) {
                    return DropdownMenuItem<String>(
                      value: currencyCode,
                      child: Text(_currencies[currencyCode]!),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _convertCurrency,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue, // Set the button text color to white
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Convertir',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _toggleFavoriteCurrency(_selectedDestinationCurrency),
        child: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

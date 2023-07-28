import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toolbox/api_key.dart';
import 'package:toolbox/translations.dart';

class PhoneValidationScreen extends StatefulWidget {
  const PhoneValidationScreen({Key? key}) : super(key: key);

  @override
  PhoneValidationScreenState createState() => PhoneValidationScreenState();
}

class PhoneValidationScreenState extends State<PhoneValidationScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  Map<String, dynamic> _validationResult = {};

  Future<void> _validatePhoneNumber() async {
    String apiUrl = 'http://apilayer.net/api/validate';
    String apiKey = APIKey.phoneValidatorAPIKey;

    String phoneNumber = _phoneNumberController.text;
    String countryCode = 'BE';
    String format = '1';

    try {
      final response = await http.get(
        Uri.parse('$apiUrl?access_key=$apiKey&number=$phoneNumber&country_code=$countryCode&format=$format'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _validationResult = data;
        });
      } else {
        setState(() {
          _validationResult = {};
        });
      }
    } catch (error) {
      setState(() {
        _validationResult = {};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: phonesTranslations['Enter Phone Number']!,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _validatePhoneNumber,
              child: const Text('Validate'),
            ),
            const SizedBox(height: 16),
            if (_validationResult.isNotEmpty) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Valid', _getValidationStatus()),
                      _buildInfoRow('Number', _getNumber()),
                      _buildInfoRow('Local Format', _getLocalFormat()),
                      _buildInfoRow('International Format', _getInternationalFormat()),
                      _buildInfoRow('Country Prefix', _getCountryPrefix()),
                      _buildInfoRow('Country Code', _getCountryCode()),
                      _buildInfoRow('Country Name', _getCountryName()),
                      _buildInfoRow('Location', _getLocation()),
                      _buildInfoRow('Carrier', _getCarrier()),
                      _buildInfoRow('Line Type', _getLineType()),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(phonesTranslations[label]!,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  String _getValidationStatus() {
    return _validationResult['valid'] == true
        ? phonesTranslations['true']!
        : phonesTranslations['false']!;
  }

  String _getNumber() {
    return _validationResult['number'];
  }

  String _getLocalFormat() {
    return _validationResult['local_format'];
  }

  String _getInternationalFormat() {
    return _validationResult['international_format'];
  }

  String _getCountryPrefix() {
    return _validationResult['country_prefix'];
  }

  String _getCountryCode() {
    return _validationResult['country_code'];
  }

  String _getCountryName() {
    return _validationResult['country_name'];
  }

  String _getLocation() {
    return _validationResult['location'];
  }

  String _getCarrier() {
    return _validationResult['carrier'];
  }

  String _getLineType() {
    return _validationResult['line_type'];
  }

}

void main() {
  runApp(MaterialApp(
    home: const PhoneValidationScreen(),
    supportedLocales: const [
      Locale('fr', ''),
    ],
    localeResolutionCallback: (locale, supportedLocales) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale!.languageCode) {
          return supportedLocale;
        }
      }
      return supportedLocales.first;
    },
  ));
}

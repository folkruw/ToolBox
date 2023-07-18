import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toolbox/countries/translations.dart';
import 'package:toolbox/countries/utils.dart';

class CountryDetailsPage extends StatelessWidget {
  final dynamic country;
  final List<dynamic> countriesData;

  const CountryDetailsPage({Key? key, required this.country, required this.countriesData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String region = country['region'] != null ? getTranslation(country['region'], continentTranslations) : 'Non disponible';

    return Scaffold(
      appBar: AppBar(
        title: Text(country['translations']['fra']['common']),
      ),
      body: SingleChildScrollView( // Wrap the Column with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Center(
                  child: Image.network(
                    country['flags']['png'],
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              buildInfoRow('Continent', region),
              buildInfoRow('Capitale', country['capital'] != null ? getTranslation(country['capital'][0], capitalTranslations) : 'Non disponible'),
              buildInfoRowNumber('Population', country['population'] ?? 'Non disponible'),
              buildInfoRowNumber('Superficie', country['area'] ?? 'Non disponible'),
              buildInfoRow('Indicatif téléphonique', country['idd'] != null ? "${country['idd']['root']}${country['idd']['suffixes'][0]}" : 'Non disponible'),
              const SizedBox(height: 8.0),
              buildListInfoRow('Langues', getLanguageList(country['languages'])),
              buildListInfoRow('Monnaie', getCurrencyList(country['currencies'])),
              buildListInfoRow('Fuseaux horaires', getTimezoneList(country['timezones'])),
              buildListInfoRow('Domaines Internet', getDomainList(country['tld'])),
              buildBorderCountriesList('Frontières', country['borders'], countriesData, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              '$label :',
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRowNumber(String label, dynamic value) {
    var formattedValue = "";
    if (label == "Superficie") {
      formattedValue = value != null ? "${NumberFormat.decimalPattern().format(value)} km²" : 'Non disponible';
    } else {
      formattedValue = value != null ? "${NumberFormat.decimalPattern().format(value)} habitants" : 'Non disponible';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              '$label :',
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              formattedValue,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListInfoRow(String label, Widget listWidget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label :',
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          listWidget,
        ],
      ),
    );
  }

  Widget getLanguageList(Map<String, dynamic>? languages) {
    if (languages != null && languages.isNotEmpty) {
      final sortedLanguages = languages.entries.toList()
        ..sort((b, a) => a.value.compareTo(b.value));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sortedLanguages.map((entry) {
          final languageName = entry.value;
          return Text(
            ' ${getTranslation(languageName, languageTranslations)}',
            style: const TextStyle(fontSize: 16.0),
          );
        }).toList(),
      );
    } else {
      return const Text(
        'Non disponible',
        style: TextStyle(fontSize: 16.0),
      );
    }
  }

  Widget getCurrencyList(Map<String, dynamic>? currencies) {
    if (currencies != null && currencies.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: currencies.keys.map((currencyCode) {
          final currencyName = currencies[currencyCode]['name'];
          final currencySymbol = currencies[currencyCode]['symbol'];
          return Text(
            ' $currencyName ($currencySymbol - $currencyCode)',
            style: const TextStyle(fontSize: 16.0),
          );
        }).toList(),
      );
    } else {
      return const Text(
        'Non disponible',
        style: TextStyle(fontSize: 16.0),
      );
    }
  }

  Widget getTimezoneList(List<dynamic>? timezones) {
    if (timezones != null && timezones.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: timezones.map((timezone) {
          return Text(
            ' $timezone',
            style: const TextStyle(fontSize: 16.0),
          );
        }).toList(),
      );
    } else {
      return const Text(
        'Non disponible',
        style: TextStyle(fontSize: 16.0),
      );
    }
  }

  Widget getDomainList(List<dynamic>? tlds) {
    if (tlds != null && tlds.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tlds.map((tld) {
          return Text(
            ' $tld',
            style: const TextStyle(fontSize: 16.0),
          );
        }).toList(),
      );
    } else {
      return const Text(
        'Non disponible',
        style: TextStyle(fontSize: 16.0),
      );
    }
  }

  Widget buildBorderCountriesList(String label, List<dynamic>? borders, List<dynamic> countriesData, BuildContext context) {
    if (borders != null && borders.isNotEmpty) {
      // Tri des pays frontaliers par ordre alphabétique
      borders.sort((a, b) {
        final countryA = countriesData.firstWhere((country) => country['cca3'] == a, orElse: () => null);
        final countryB = countriesData.firstWhere((country) => country['cca3'] == b, orElse: () => null);
        if (countryA != null && countryB != null) {
          final nameA = countryA['translations']['fra']['common'];
          final nameB = countryB['translations']['fra']['common'];
          return nameA.compareTo(nameB);
        }
        return 0;
      });
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label :',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: borders.map((border) {
              final borderCountry = countriesData.firstWhere(
                    (country) => country['cca3'] == border,
                orElse: () => null,
              );
              if (borderCountry != null) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CountryDetailsPage(
                          country: borderCountry,
                          countriesData: countriesData,
                        ),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: ' ',
                      style: const TextStyle(fontSize: 16.0),
                      children: [
                        TextSpan(
                          text: borderCountry['translations']['fra']['common'],
                          style: const TextStyle(
                            fontSize: 16.0,
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }).toList(),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label :',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Aucune frontière',
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      );
    }
  }
}

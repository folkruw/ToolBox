import 'package:flutter/material.dart';
import 'country_details_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'translations.dart';

class CountriesPage extends StatefulWidget {
  const CountriesPage({Key? key}) : super(key: key);

  @override
  _CountriesPageState createState() => _CountriesPageState();
}

class _CountriesPageState extends State<CountriesPage> {
  List<dynamic> countries = [];
  List<String> continents = ['Africa', 'Americas', 'Asia', 'Europe', 'Oceania'];
  String selectedContinent = '';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('https://restcountries.com/v3.1/all'));
    if (response.statusCode == 200) {
      List<dynamic> decodedData = jsonDecode(utf8.decode(response.bodyBytes));
      decodedData.sort((a, b) => a['translations']['fra']['common'].compareTo(b['translations']['fra']['common'])); // Tri par ordre alphabétique
      setState(() {
        countries = decodedData;
      });
    } else {
      throw Exception('Impossible de récupérer les données');
    }
  }

  List<dynamic> getFilteredCountries() {
    if (searchQuery.isNotEmpty) {
      return countries.where((country) {
        final countryName = country['translations']['fra']['common'].toString().toLowerCase();
        return countryName.contains(searchQuery.toLowerCase());
      }).toList();
    } else if (selectedContinent.isNotEmpty) {
      return countries.where((country) => country['region'] == selectedContinent).toList();
    } else {
      return countries;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredCountries = getFilteredCountries();

    return Scaffold(
      appBar: null,
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2 / 2.8,
        ),
        itemCount: filteredCountries.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CountryDetailsPage(
                    country: filteredCountries[index],
                    countriesData: countries,
                  ),
                ),
              );
            },
            child: Card(
              elevation: 0,
              color: Colors.transparent,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      filteredCountries[index]['flags']['png'],
                      height: 100,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    filteredCountries[index]['translations']['fra']['common'],
                    style: const TextStyle(fontSize: 16.0),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: continents.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return ListTile(
                        title: const Text('Tous les continents'),
                        onTap: () {
                          setState(() {
                            selectedContinent = '';
                          });
                          Navigator.pop(context);
                        },
                      );
                    } else {
                      final continent = continents[index - 1];
                      final translation = continentTranslations[continent];
                      return ListTile(
                        title: Text(translation ?? ''),
                        onTap: () {
                          setState(() {
                            selectedContinent = continent;
                          });
                          Navigator.pop(context);
                        },
                      );
                    }
                  },
                ),
              );
            },
          );
        },
        child: const Icon(Icons.filter_list),
      ),
    );
  }
}

class CountrySearchDelegate extends SearchDelegate {
  final List<dynamic> countries;

  CountrySearchDelegate({required this.countries});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Not used in this case
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<dynamic> suggestions = [];

    if (query.isNotEmpty) {
      suggestions.addAll(countries.where((country) {
        final countryName = country['translations']['fra']['common'].toString().toLowerCase();
        return countryName.contains(query.toLowerCase());
      }));
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int index) {
        final country = suggestions[index];
        return ListTile(
          title: Text(country['translations']['fra']['common']),
          onTap: () {
            close(context, '');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CountryDetailsPage(
                  country: country,
                  countriesData: countries,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

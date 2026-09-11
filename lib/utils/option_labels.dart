import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart';

/// Option A: canonical values stay GERMAN in Supabase.
/// This helper only translates the DISPLAY label.
/// Unknown values fall back to the raw value (safe for legacy/free-text data).
String optLabel(BuildContext context, String value) {
  final t = AppLocalizations.of(context)!;
  switch (value.trim()) {
    // Charakter & Eigenschaften
    case 'Humorvoll': return t.optHumorvoll;
    case 'Romantisch': return t.optRomantisch;
    case 'Sportlich': return t.optSportlich;
    case 'Famili\u00e4r':
    case 'Familiaer': return t.optFamiliaer;
    case 'Zuverl\u00e4ssig':
    case 'Zuverlaessig': return t.optZuverlaessig;
    case 'Ehrgeizig': return t.optEhrgeizig;
    case 'Herzlich': return t.optHerzlich;
    case 'Weltoffen': return t.optWeltoffen;
    case 'Traditionell': return t.optTraditionell;
    case 'Spontan': return t.optSpontan;
    case 'Kreativ': return t.optKreativ;
    case 'Spirituell': return t.optSpirituell;
    case 'F\u00fcrsorglich':
    case 'Fuersorglich': return t.optFuersorglich;
    case 'Liebevoll': return t.optLiebevoll;
    case 'Gelassen': return t.optGelassen;
    case 'Sch\u00fcchtern':
    case 'Schuechtern': return t.optSchuechtern;
    case 'Zielstrebig': return t.optZielstrebig;
    case 'Abenteuerlustig': return t.optAbenteuerlustig;
    case 'Empathisch': return t.optEmpathisch;
    case 'Loyal': return t.optLoyal;
    // Interessen & Hobbys
    case 'Sport & Fitness': return t.optIntSportFitness;
    case 'Zeit mit Familie': return t.optIntFamilyTime;
    case 'Kochen & Essen': return t.optIntCooking;
    case 'Reisen': return t.optIntTravel;
    case 'Lesen & Lernen': return t.optIntReading;
    case 'Gaming & Filme': return t.optIntGaming;
    case 'Musik & Tanzen': return t.optIntMusic;
    case 'Natur & Spazieren': return t.optIntNature;
    case 'Caf\u00e9 & Freunde':
    case 'Cafe & Freunde': return t.optIntCafe;
    case 'Fotografie': return t.optIntPhoto;
    case 'Autos & Technik': return t.optIntCars;
    case 'Kunst & Design': return t.optIntArt;
    // Sport
    case 'Fitness': return t.optSpFitness;
    case 'Fu\u00dfball':
    case 'Fussball': return t.optSpFootball;
    case 'Schwimmen': return t.optSpSwimming;
    case 'Joggen': return t.optSpJogging;
    case 'Yoga': return t.optSpYoga;
    case 'Boxen': return t.optSpBoxing;
    case 'Basketball': return t.optSpBasketball;
    case 'Tennis': return t.optSpTennis;
    case 'Kampfsport': return t.optSpMartial;
    case 'Tanzen': return t.optSpDancing;
    case 'Radfahren': return t.optSpCycling;
    case 'Wandern': return t.optSpHiking;
    // Reisen
    case 'Strandurlaub': return t.optTrBeach;
    case 'St\u00e4dtereisen':
    case 'Staedtereisen': return t.optTrCity;
    case 'Aktivurlaub': return t.optTrActive;
    case 'Camping & Natur': return t.optTrCamping;
    case 'Wellness': return t.optTrWellness;
    case 'Backpacking': return t.optTrBackpacking;
    case 'Familienurlaub': return t.optTrFamily;
    case 'Kreuzfahrt': return t.optTrCruise;
    default: return value;
  }
}

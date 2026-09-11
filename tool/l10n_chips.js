// Adds chip/option labels to app_de.arb + app_en.arb (Option A: DB stays German)
const fs = require('fs');
const T = [
  ['optHumorvoll','Humorvoll','Funny'],
  ['optRomantisch','Romantisch','Romantic'],
  ['optSportlich','Sportlich','Athletic'],
  ['optFamiliaer','Famili\u00e4r','Family-oriented'],
  ['optZuverlaessig','Zuverl\u00e4ssig','Reliable'],
  ['optEhrgeizig','Ehrgeizig','Ambitious'],
  ['optHerzlich','Herzlich','Warm-hearted'],
  ['optWeltoffen','Weltoffen','Open-minded'],
  ['optTraditionell','Traditionell','Traditional'],
  ['optSpontan','Spontan','Spontaneous'],
  ['optKreativ','Kreativ','Creative'],
  ['optSpirituell','Spirituell','Spiritual'],
  ['optFuersorglich','F\u00fcrsorglich','Caring'],
  ['optLiebevoll','Liebevoll','Loving'],
  ['optGelassen','Gelassen','Easy-going'],
  ['optSchuechtern','Sch\u00fcchtern','Shy'],
  ['optZielstrebig','Zielstrebig','Determined'],
  ['optAbenteuerlustig','Abenteuerlustig','Adventurous'],
  ['optEmpathisch','Empathisch','Empathetic'],
  ['optLoyal','Loyal','Loyal'],
  ['optIntSportFitness','Sport & Fitness','Sports & Fitness'],
  ['optIntFamilyTime','Zeit mit Familie','Time with family'],
  ['optIntCooking','Kochen & Essen','Cooking & Food'],
  ['optIntTravel','Reisen','Travelling'],
  ['optIntReading','Lesen & Lernen','Reading & Learning'],
  ['optIntGaming','Gaming & Filme','Gaming & Movies'],
  ['optIntMusic','Musik & Tanzen','Music & Dancing'],
  ['optIntNature','Natur & Spazieren','Nature & Walks'],
  ['optIntCafe','Caf\u00e9 & Freunde','Caf\u00e9 & Friends'],
  ['optIntPhoto','Fotografie','Photography'],
  ['optIntCars','Autos & Technik','Cars & Tech'],
  ['optIntArt','Kunst & Design','Art & Design'],
  ['optSpFitness','Fitness','Fitness'],
  ['optSpFootball','Fu\u00dfball','Football'],
  ['optSpSwimming','Schwimmen','Swimming'],
  ['optSpJogging','Joggen','Running'],
  ['optSpYoga','Yoga','Yoga'],
  ['optSpBoxing','Boxen','Boxing'],
  ['optSpBasketball','Basketball','Basketball'],
  ['optSpTennis','Tennis','Tennis'],
  ['optSpMartial','Kampfsport','Martial arts'],
  ['optSpDancing','Tanzen','Dancing'],
  ['optSpCycling','Radfahren','Cycling'],
  ['optSpHiking','Wandern','Hiking'],
  ['optTrBeach','Strandurlaub','Beach holiday'],
  ['optTrCity','St\u00e4dtereisen','City trips'],
  ['optTrActive','Aktivurlaub','Active holiday'],
  ['optTrCamping','Camping & Natur','Camping & Nature'],
  ['optTrWellness','Wellness','Wellness'],
  ['optTrBackpacking','Backpacking','Backpacking'],
  ['optTrFamily','Familienurlaub','Family holiday'],
  ['optTrCruise','Kreuzfahrt','Cruise'],
];
function patch(file, idx) {
  const j = JSON.parse(fs.readFileSync(file, 'utf8'));
  let added = 0, skipped = 0;
  for (const row of T) {
    if (j[row[0]] !== undefined) { skipped++; continue; }
    j[row[0]] = row[idx];
    added++;
  }
  fs.writeFileSync(file, JSON.stringify(j, null, 2) + '\n', 'utf8');
  console.log(file + ': +' + added + ' added, ' + skipped + ' already present');
}
patch('lib/l10n/app_de.arb', 1);
patch('lib/l10n/app_en.arb', 2);

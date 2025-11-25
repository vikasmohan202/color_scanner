import 'dart:math' as Math;
import 'dart:ui';

class RALConverter {
  // RAL Classic color database with closest matches
  static final List<Map<String, dynamic>> ralColors = [
    {
      'code': 'RAL 1000',
      'name': 'Green beige',
      'rgb': [206, 191, 139]
    },
    {
      'code': 'RAL 1001',
      'name': 'Beige',
      'rgb': [208, 176, 132]
    },
    {
      'code': 'RAL 1002',
      'name': 'Sand yellow',
      'rgb': [213, 170, 109]
    },
    {
      'code': 'RAL 1003',
      'name': 'Signal yellow',
      'rgb': [249, 168, 0]
    },
    {
      'code': 'RAL 1004',
      'name': 'Golden yellow',
      'rgb': [228, 158, 0]
    },
    {
      'code': 'RAL 1005',
      'name': 'Honey yellow',
      'rgb': [203, 142, 30]
    },
    {
      'code': 'RAL 1006',
      'name': 'Maize yellow',
      'rgb': [226, 144, 0]
    },
    {
      'code': 'RAL 1007',
      'name': 'Daffodil yellow',
      'rgb': [232, 140, 0]
    },
    {
      'code': 'RAL 1011',
      'name': 'Brown beige',
      'rgb': [175, 128, 79]
    },
    {
      'code': 'RAL 1012',
      'name': 'Lemon yellow',
      'rgb': [247, 182, 0]
    },
    {
      'code': 'RAL 1013',
      'name': 'Oyster white',
      'rgb': [237, 229, 218]
    },
    {
      'code': 'RAL 1014',
      'name': 'Ivory',
      'rgb': [229, 210, 168]
    },
    {
      'code': 'RAL 1015',
      'name': 'Light ivory',
      'rgb': [246, 228, 193]
    },
    {
      'code': 'RAL 1016',
      'name': 'Sulfur yellow',
      'rgb': [253, 217, 0]
    },
    {
      'code': 'RAL 1017',
      'name': 'Saffron yellow',
      'rgb': [250, 178, 0]
    },
    {
      'code': 'RAL 1018',
      'name': 'Zinc yellow',
      'rgb': [252, 200, 0]
    },
    {
      'code': 'RAL 1019',
      'name': 'Grey beige',
      'rgb': [162, 143, 122]
    },
    {
      'code': 'RAL 1020',
      'name': 'Olive yellow',
      'rgb': [158, 143, 101]
    },
    {
      'code': 'RAL 1021',
      'name': 'Rape yellow',
      'rgb': [249, 154, 0]
    },
    {
      'code': 'RAL 1023',
      'name': 'Traffic yellow',
      'rgb': [250, 157, 0]
    },
    {
      'code': 'RAL 1024',
      'name': 'Ochre yellow',
      'rgb': [180, 132, 85]
    },
    {
      'code': 'RAL 1026',
      'name': 'Luminous yellow',
      'rgb': [255, 255, 0]
    },
    {
      'code': 'RAL 1027',
      'name': 'Curry',
      'rgb': [167, 127, 14]
    },
    {
      'code': 'RAL 1028',
      'name': 'Melon yellow',
      'rgb': [255, 117, 20]
    },
    {
      'code': 'RAL 1032',
      'name': 'Broom yellow',
      'rgb': [218, 164, 32]
    },
    {
      'code': 'RAL 1033',
      'name': 'Dahlia yellow',
      'rgb': [234, 137, 0]
    },
    {
      'code': 'RAL 1034',
      'name': 'Pastel yellow',
      'rgb': [222, 176, 91]
    },
    {
      'code': 'RAL 1035',
      'name': 'Pearl beige',
      'rgb': [135, 118, 92]
    },
    {
      'code': 'RAL 1036',
      'name': 'Pearl gold',
      'rgb': [125, 103, 56]
    },
    {
      'code': 'RAL 1037',
      'name': 'Sun yellow',
      'rgb': [255, 155, 0]
    },
    {
      'code': 'RAL 2000',
      'name': 'Yellow orange',
      'rgb': [221, 117, 0]
    },
    {
      'code': 'RAL 2001',
      'name': 'Red orange',
      'rgb': [190, 60, 22]
    },
    {
      'code': 'RAL 2002',
      'name': 'Vermilion',
      'rgb': [203, 53, 31]
    },
    {
      'code': 'RAL 2003',
      'name': 'Pastel orange',
      'rgb': [255, 117, 20]
    },
    {
      'code': 'RAL 2004',
      'name': 'Pure orange',
      'rgb': [255, 77, 6]
    },
    {
      'code': 'RAL 2005',
      'name': 'Luminous orange',
      'rgb': [255, 60, 0]
    },
    {
      'code': 'RAL 2007',
      'name': 'Luminous bright orange',
      'rgb': [255, 179, 0]
    },
    {
      'code': 'RAL 2008',
      'name': 'Bright red orange',
      'rgb': [237, 107, 33]
    },
    {
      'code': 'RAL 2009',
      'name': 'Traffic orange',
      'rgb': [222, 83, 7]
    },
    {
      'code': 'RAL 2010',
      'name': 'Signal orange',
      'rgb': [213, 94, 0]
    },
    {
      'code': 'RAL 2011',
      'name': 'Deep orange',
      'rgb': [188, 64, 18]
    },
    {
      'code': 'RAL 2012',
      'name': 'Salmon orange',
      'rgb': [222, 110, 93]
    },
    {
      'code': 'RAL 2013',
      'name': 'Pearl orange',
      'rgb': [168, 90, 50]
    },
    {
      'code': 'RAL 3000',
      'name': 'Flame red',
      'rgb': [164, 52, 40]
    },
    {
      'code': 'RAL 3001',
      'name': 'Signal red',
      'rgb': [155, 36, 35]
    },
    {
      'code': 'RAL 3002',
      'name': 'Carmine red',
      'rgb': [155, 35, 33]
    },
    {
      'code': 'RAL 3003',
      'name': 'Ruby red',
      'rgb': [134, 26, 34]
    },
    {
      'code': 'RAL 3004',
      'name': 'Purple red',
      'rgb': [107, 28, 35]
    },
    {
      'code': 'RAL 3005',
      'name': 'Wine red',
      'rgb': [89, 25, 31]
    },
    {
      'code': 'RAL 3007',
      'name': 'Black red',
      'rgb': [62, 32, 34]
    },
    {
      'code': 'RAL 3009',
      'name': 'Oxide red',
      'rgb': [109, 52, 45]
    },
    {
      'code': 'RAL 3011',
      'name': 'Brown red',
      'rgb': [121, 59, 47]
    },
    {
      'code': 'RAL 3012',
      'name': 'Beige red',
      'rgb': [198, 132, 109]
    },
    {
      'code': 'RAL 3013',
      'name': 'Tomato red',
      'rgb': [203, 115, 99]
    },
    {
      'code': 'RAL 3014',
      'name': 'Antique pink',
      'rgb': [216, 160, 166]
    },
    {
      'code': 'RAL 3015',
      'name': 'Light pink',
      'rgb': [231, 150, 139]
    },
    {
      'code': 'RAL 3016',
      'name': 'Coral red',
      'rgb': [181, 69, 62]
    },
    {
      'code': 'RAL 3017',
      'name': 'Rose',
      'rgb': [186, 59, 70]
    },
    {
      'code': 'RAL 3018',
      'name': 'Strawberry red',
      'rgb': [198, 52, 57]
    },
    {
      'code': 'RAL 3020',
      'name': 'Traffic red',
      'rgb': [204, 44, 36]
    },
    {
      'code': 'RAL 3022',
      'name': 'Salmon pink',
      'rgb': [208, 93, 97]
    },
    {
      'code': 'RAL 3024',
      'name': 'Luminous red',
      'rgb': [255, 42, 27]
    },
    {
      'code': 'RAL 3026',
      'name': 'Luminous bright red',
      'rgb': [255, 36, 0]
    },
    {
      'code': 'RAL 3027',
      'name': 'Raspberry red',
      'rgb': [179, 40, 52]
    },
    {
      'code': 'RAL 3028',
      'name': 'Pure red',
      'rgb': [204, 44, 36]
    },
    {
      'code': 'RAL 3031',
      'name': 'Orient red',
      'rgb': [166, 52, 55]
    },
    {
      'code': 'RAL 3032',
      'name': 'Pearl ruby red',
      'rgb': [112, 48, 50]
    },
    {
      'code': 'RAL 3033',
      'name': 'Pearl pink',
      'rgb': [164, 87, 89]
    },
    {
      'code': 'RAL 4001',
      'name': 'Red lilac',
      'rgb': [129, 97, 131]
    },
    {
      'code': 'RAL 4002',
      'name': 'Red violet',
      'rgb': [141, 60, 75]
    },
    {
      'code': 'RAL 4003',
      'name': 'Heather violet',
      'rgb': [196, 97, 140]
    },
    {
      'code': 'RAL 4004',
      'name': 'Claret violet',
      'rgb': [101, 30, 56]
    },
    {
      'code': 'RAL 4005',
      'name': 'Blue lilac',
      'rgb': [118, 104, 154]
    },
    {
      'code': 'RAL 4006',
      'name': 'Traffic purple',
      'rgb': [144, 51, 115]
    },
    {
      'code': 'RAL 4007',
      'name': 'Purple violet',
      'rgb': [71, 36, 60]
    },
    {
      'code': 'RAL 4008',
      'name': 'Signal violet',
      'rgb': [132, 76, 130]
    },
    {
      'code': 'RAL 4009',
      'name': 'Pastel violet',
      'rgb': [157, 134, 146]
    },
    {
      'code': 'RAL 4010',
      'name': 'Telemagenta',
      'rgb': [188, 64, 119]
    },
    {
      'code': 'RAL 4011',
      'name': 'Pearl violet',
      'rgb': [108, 91, 119]
    },
    {
      'code': 'RAL 4012',
      'name': 'Pearl blackberry',
      'rgb': [104, 83, 104]
    },
    {
      'code': 'RAL 5000',
      'name': 'Violet blue',
      'rgb': [63, 73, 133]
    },
    {
      'code': 'RAL 5001',
      'name': 'Green blue',
      'rgb': [34, 47, 83]
    },
    {
      'code': 'RAL 5002',
      'name': 'Ultramarine blue',
      'rgb': [31, 41, 93]
    },
    {
      'code': 'RAL 5003',
      'name': 'Sapphire blue',
      'rgb': [25, 30, 66]
    },
    {
      'code': 'RAL 5004',
      'name': 'Black blue',
      'rgb': [29, 32, 53]
    },
    {
      'code': 'RAL 5005',
      'name': 'Signal blue',
      'rgb': [0, 83, 135]
    },
    {
      'code': 'RAL 5007',
      'name': 'Brilliant blue',
      'rgb': [63, 105, 170]
    },
    {
      'code': 'RAL 5008',
      'name': 'Grey blue',
      'rgb': [34, 51, 77]
    },
    {
      'code': 'RAL 5009',
      'name': 'Azure blue',
      'rgb': [31, 56, 85]
    },
    {
      'code': 'RAL 5010',
      'name': 'Gentian blue',
      'rgb': [25, 30, 66]
    },
    {
      'code': 'RAL 5011',
      'name': 'Steel blue',
      'rgb': [29, 52, 87]
    },
    {
      'code': 'RAL 5012',
      'name': 'Light blue',
      'rgb': [0, 137, 182]
    },
    {
      'code': 'RAL 5013',
      'name': 'Cobalt blue',
      'rgb': [25, 49, 83]
    },
    {
      'code': 'RAL 5014',
      'name': 'Pigeon blue',
      'rgb': [96, 110, 140]
    },
    {
      'code': 'RAL 5015',
      'name': 'Sky blue',
      'rgb': [0, 124, 176]
    },
    {
      'code': 'RAL 5017',
      'name': 'Traffic blue',
      'rgb': [0, 91, 140]
    },
    {
      'code': 'RAL 5018',
      'name': 'Turquoise blue',
      'rgb': [0, 131, 142]
    },
    {
      'code': 'RAL 5019',
      'name': 'Capri blue',
      'rgb': [0, 94, 131]
    },
    {
      'code': 'RAL 5020',
      'name': 'Ocean blue',
      'rgb': [0, 65, 83]
    },
    {
      'code': 'RAL 5021',
      'name': 'Water blue',
      'rgb': [0, 117, 119]
    },
    {
      'code': 'RAL 5022',
      'name': 'Night blue',
      'rgb': [33, 46, 82]
    },
    {
      'code': 'RAL 5023',
      'name': 'Distant blue',
      'rgb': [101, 136, 159]
    },
    {
      'code': 'RAL 5024',
      'name': 'Pastel blue',
      'rgb': [71, 104, 135]
    },
    {
      'code': 'RAL 5025',
      'name': 'Pearl gentian blue',
      'rgb': [52, 79, 113]
    },
    {
      'code': 'RAL 5026',
      'name': 'Pearl night blue',
      'rgb': [29, 38, 62]
    },
    {
      'code': 'RAL 6000',
      'name': 'Patina green',
      'rgb': [65, 95, 66]
    },
    {
      'code': 'RAL 6001',
      'name': 'Emerald green',
      'rgb': [47, 87, 53]
    },
    {
      'code': 'RAL 6002',
      'name': 'Leaf green',
      'rgb': [44, 85, 69]
    },
    {
      'code': 'RAL 6003',
      'name': 'Olive green',
      'rgb': [58, 75, 57]
    },
    {
      'code': 'RAL 6004',
      'name': 'Blue green',
      'rgb': [28, 47, 46]
    },
    {
      'code': 'RAL 6005',
      'name': 'Moss green',
      'rgb': [35, 47, 44]
    },
    {
      'code': 'RAL 6006',
      'name': 'Grey olive',
      'rgb': [78, 83, 73]
    },
    {
      'code': 'RAL 6007',
      'name': 'Bottle green',
      'rgb': [44, 50, 48]
    },
    {
      'code': 'RAL 6008',
      'name': 'Brown green',
      'rgb': [55, 60, 50]
    },
    {
      'code': 'RAL 6009',
      'name': 'Fir green',
      'rgb': [39, 53, 49]
    },
    {
      'code': 'RAL 6010',
      'name': 'Grass green',
      'rgb': [77, 111, 57]
    },
    {
      'code': 'RAL 6011',
      'name': 'Reseda green',
      'rgb': [108, 124, 89]
    },
    {
      'code': 'RAL 6012',
      'name': 'Black green',
      'rgb': [48, 61, 58]
    },
    {
      'code': 'RAL 6013',
      'name': 'Reed green',
      'rgb': [125, 118, 90]
    },
    {
      'code': 'RAL 6014',
      'name': 'Yellow olive',
      'rgb': [71, 69, 53]
    },
    {
      'code': 'RAL 6015',
      'name': 'Black olive',
      'rgb': [61, 64, 53]
    },
    {
      'code': 'RAL 6016',
      'name': 'Turquoise green',
      'rgb': [0, 139, 108]
    },
    {
      'code': 'RAL 6017',
      'name': 'May green',
      'rgb': [76, 145, 65]
    },
    {
      'code': 'RAL 6018',
      'name': 'Yellow green',
      'rgb': [91, 158, 64]
    },
    {
      'code': 'RAL 6019',
      'name': 'Pastel green',
      'rgb': [172, 191, 143]
    },
    {
      'code': 'RAL 6020',
      'name': 'Chrome green',
      'rgb': [53, 66, 57]
    },
    {
      'code': 'RAL 6021',
      'name': 'Pale green',
      'rgb': [130, 151, 103]
    },
    {
      'code': 'RAL 6022',
      'name': 'Olive drab',
      'rgb': [55, 66, 47]
    },
    {
      'code': 'RAL 6024',
      'name': 'Traffic green',
      'rgb': [0, 131, 81]
    },
    {
      'code': 'RAL 6025',
      'name': 'Fern green',
      'rgb': [77, 111, 57]
    },
    {
      'code': 'RAL 6026',
      'name': 'Opal green',
      'rgb': [0, 95, 78]
    },
    {
      'code': 'RAL 6027',
      'name': 'Light green',
      'rgb': [0, 163, 150]
    },
    {
      'code': 'RAL 6028',
      'name': 'Pine green',
      'rgb': [34, 61, 52]
    },
    {
      'code': 'RAL 6029',
      'name': 'Mint green',
      'rgb': [73, 126, 118]
    },
    {
      'code': 'RAL 6032',
      'name': 'Signal green',
      'rgb': [0, 133, 94]
    },
    {
      'code': 'RAL 6033',
      'name': 'Mint turquoise',
      'rgb': [52, 150, 143]
    },
    {
      'code': 'RAL 6034',
      'name': 'Pastel turquoise',
      'rgb': [122, 172, 172]
    },
    {
      'code': 'RAL 6035',
      'name': 'Pearl green',
      'rgb': [70, 102, 89]
    },
    {
      'code': 'RAL 6036',
      'name': 'Pearl opal green',
      'rgb': [0, 119, 104]
    },
    {
      'code': 'RAL 6037',
      'name': 'Pure green',
      'rgb': [0, 139, 41]
    },
    {
      'code': 'RAL 6038',
      'name': 'Luminous green',
      'rgb': [0, 187, 45]
    },
    {
      'code': 'RAL 7000',
      'name': 'Squirrel grey',
      'rgb': [122, 136, 142]
    },
    {
      'code': 'RAL 7001',
      'name': 'Silver grey',
      'rgb': [140, 150, 157]
    },
    {
      'code': 'RAL 7002',
      'name': 'Olive grey',
      'rgb': [129, 120, 99]
    },
    {
      'code': 'RAL 7003',
      'name': 'Moss grey',
      'rgb': [122, 118, 105]
    },
    {
      'code': 'RAL 7004',
      'name': 'Signal grey',
      'rgb': [155, 155, 155]
    },
    {
      'code': 'RAL 7005',
      'name': 'Mouse grey',
      'rgb': [108, 110, 107]
    },
    {
      'code': 'RAL 7006',
      'name': 'Beige grey',
      'rgb': [118, 106, 94]
    },
    {
      'code': 'RAL 7008',
      'name': 'Khaki grey',
      'rgb': [116, 94, 61]
    },
    {
      'code': 'RAL 7009',
      'name': 'Green grey',
      'rgb': [93, 96, 88]
    },
    {
      'code': 'RAL 7010',
      'name': 'Tarpaulin grey',
      'rgb': [88, 92, 86]
    },
    {
      'code': 'RAL 7011',
      'name': 'Iron grey',
      'rgb': [82, 89, 93]
    },
    {
      'code': 'RAL 7012',
      'name': 'Basalt grey',
      'rgb': [87, 93, 94]
    },
    {
      'code': 'RAL 7013',
      'name': 'Brown grey',
      'rgb': [87, 80, 68]
    },
    {
      'code': 'RAL 7015',
      'name': 'Slate grey',
      'rgb': [79, 83, 88]
    },
    {
      'code': 'RAL 7016',
      'name': 'Anthracite grey',
      'rgb': [56, 62, 66]
    },
    {
      'code': 'RAL 7021',
      'name': 'Black grey',
      'rgb': [47, 50, 52]
    },
    {
      'code': 'RAL 7022',
      'name': 'Umbra grey',
      'rgb': [76, 74, 68]
    },
    {
      'code': 'RAL 7023',
      'name': 'Concrete grey',
      'rgb': [128, 128, 118]
    },
    {
      'code': 'RAL 7024',
      'name': 'Graphite grey',
      'rgb': [69, 73, 78]
    },
    {
      'code': 'RAL 7026',
      'name': 'Granite grey',
      'rgb': [55, 67, 69]
    },
    {
      'code': 'RAL 7030',
      'name': 'Stone grey',
      'rgb': [146, 142, 133]
    },
    {
      'code': 'RAL 7031',
      'name': 'Blue grey',
      'rgb': [91, 104, 109]
    },
    {
      'code': 'RAL 7032',
      'name': 'Pebble grey',
      'rgb': [181, 176, 161]
    },
    {
      'code': 'RAL 7033',
      'name': 'Cement grey',
      'rgb': [127, 130, 116]
    },
    {
      'code': 'RAL 7034',
      'name': 'Yellow grey',
      'rgb': [146, 136, 111]
    },
    {
      'code': 'RAL 7035',
      'name': 'Light grey',
      'rgb': [197, 199, 196]
    },
    {
      'code': 'RAL 7036',
      'name': 'Platinum grey',
      'rgb': [151, 147, 146]
    },
    {
      'code': 'RAL 7037',
      'name': 'Dusty grey',
      'rgb': [122, 123, 122]
    },
    {
      'code': 'RAL 7038',
      'name': 'Agate grey',
      'rgb': [176, 176, 169]
    },
    {
      'code': 'RAL 7039',
      'name': 'Quartz grey',
      'rgb': [107, 102, 94]
    },
    {
      'code': 'RAL 7040',
      'name': 'Window grey',
      'rgb': [152, 158, 161]
    },
    {
      'code': 'RAL 7042',
      'name': 'Traffic grey A',
      'rgb': [142, 146, 145]
    },
    {
      'code': 'RAL 7043',
      'name': 'Traffic grey B',
      'rgb': [79, 82, 80]
    },
    {
      'code': 'RAL 7044',
      'name': 'Silk grey',
      'rgb': [183, 179, 168]
    },
    {
      'code': 'RAL 7045',
      'name': 'Telegrey 1',
      'rgb': [141, 146, 149]
    },
    {
      'code': 'RAL 7046',
      'name': 'Telegrey 2',
      'rgb': [127, 134, 138]
    },
    {
      'code': 'RAL 7047',
      'name': 'Telegrey 4',
      'rgb': [200, 200, 199]
    },
    {
      'code': 'RAL 7048',
      'name': 'Pearl mouse grey',
      'rgb': [129, 123, 115]
    },
    {
      'code': 'RAL 8000',
      'name': 'Green brown',
      'rgb': [137, 105, 62]
    },
    {
      'code': 'RAL 8001',
      'name': 'Ochre brown',
      'rgb': [157, 98, 43]
    },
    {
      'code': 'RAL 8002',
      'name': 'Signal brown',
      'rgb': [121, 77, 62]
    },
    {
      'code': 'RAL 8003',
      'name': 'Clay brown',
      'rgb': [126, 75, 38]
    },
    {
      'code': 'RAL 8004',
      'name': 'Copper brown',
      'rgb': [141, 73, 49]
    },
    {
      'code': 'RAL 8007',
      'name': 'Fawn brown',
      'rgb': [112, 69, 42]
    },
    {
      'code': 'RAL 8008',
      'name': 'Olive brown',
      'rgb': [114, 74, 37]
    },
    {
      'code': 'RAL 8011',
      'name': 'Nut brown',
      'rgb': [90, 56, 38]
    },
    {
      'code': 'RAL 8012',
      'name': 'Red brown',
      'rgb': [102, 51, 43]
    },
    {
      'code': 'RAL 8014',
      'name': 'Sepia brown',
      'rgb': [74, 53, 38]
    },
    {
      'code': 'RAL 8015',
      'name': 'Chestnut brown',
      'rgb': [94, 47, 38]
    },
    {
      'code': 'RAL 8016',
      'name': 'Mahogany brown',
      'rgb': [76, 43, 33]
    },
    {
      'code': 'RAL 8017',
      'name': 'Chocolate brown',
      'rgb': [68, 47, 41]
    },
    {
      'code': 'RAL 8019',
      'name': 'Grey brown',
      'rgb': [61, 54, 53]
    },
    {
      'code': 'RAL 8022',
      'name': 'Black brown',
      'rgb': [26, 23, 25]
    },
    {
      'code': 'RAL 8023',
      'name': 'Orange brown',
      'rgb': [164, 87, 41]
    },
    {
      'code': 'RAL 8024',
      'name': 'Beige brown',
      'rgb': [121, 80, 56]
    },
    {
      'code': 'RAL 8025',
      'name': 'Pale brown',
      'rgb': [117, 88, 71]
    },
    {
      'code': 'RAL 8028',
      'name': 'Terracotta',
      'rgb': [140, 73, 57]
    },
    {
      'code': 'RAL 8029',
      'name': 'Pearl copper',
      'rgb': [112, 69, 42]
    },
    {
      'code': 'RAL 9001',
      'name': 'Cream',
      'rgb': [247, 237, 226]
    },
    {
      'code': 'RAL 9002',
      'name': 'Grey white',
      'rgb': [237, 234, 231]
    },
    {
      'code': 'RAL 9003',
      'name': 'Signal white',
      'rgb': [244, 244, 244]
    },
    {
      'code': 'RAL 9004',
      'name': 'Signal black',
      'rgb': [39, 39, 39]
    },
    {
      'code': 'RAL 9005',
      'name': 'Jet black',
      'rgb': [14, 14, 16]
    },
    {
      'code': 'RAL 9006',
      'name': 'White aluminium',
      'rgb': [165, 165, 165]
    },
    {
      'code': 'RAL 9007',
      'name': 'Grey aluminium',
      'rgb': [137, 137, 137]
    },
    {
      'code': 'RAL 9010',
      'name': 'Pure white',
      'rgb': [250, 255, 255]
    },
    {
      'code': 'RAL 9011',
      'name': 'Graphite black',
      'rgb': [17, 17, 19]
    },
    {
      'code': 'RAL 9016',
      'name': 'Traffic white',
      'rgb': [250, 255, 255]
    },
    {
      'code': 'RAL 9017',
      'name': 'Traffic black',
      'rgb': [23, 23, 23]
    },
    {
      'code': 'RAL 9018',
      'name': 'Papyrus white',
      'rgb': [219, 221, 213]
    },
  ];

  // Calculate color distance using Euclidean distance in RGB space
  static double _colorDistance(List<int> color1, List<int> color2) {
    return Math.sqrt(Math.pow(color1[0] - color2[0], 2) +
        Math.pow(color1[1] - color2[1], 2) +
        Math.pow(color1[2] - color2[2], 2));
  }

  // Find closest RAL color
  static Map<String, dynamic>? findClosestRAL(Color color) {
    final target = [color.red, color.green, color.blue];
    Map<String, dynamic>? closestColor;
    double minDistance = double.infinity;

    for (final ral in ralColors) {
      final distance = _colorDistance(target, ral['rgb'] as List<int>);
      if (distance < minDistance) {
        minDistance = distance;
        closestColor = ral;
      }
    }

    return closestColor;
  }
}

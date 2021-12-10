import 'package:poppos/Model/OrderModel.dart';
import 'package:poppos/Networking/OfflineData.dart';

Future<String> invoiceGenerator(Order data) async {
  String css = '''<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style id="style">
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: monospace;
        }

        .wrapper {
            width: 52mm;
            padding: 4px;
            overflow: hidden;
        }

        header {
            text-align: center;
            width: 90%;
            margin: 0 auto;
            margin-bottom: 8px;
        }

        header img {
            height: 60px;
        }

        header h1,
        header h2,
        header h3,
        header h4,
        header h5,
        header h6 {
            font-size: 16px;
        }

        header p {
            font-size: 12px;
        }

        section {
            width: 100%;
            font-size: 12px;
        }

        section h1,
        section h2,
        section h3,
        section h4,
        section h5,
        section h6 {
            font-size: 14px;
            text-align: center;
            margin-bottom: 4px;
        }

        section table {
            width: 100%;
            border-collapse: collapse;
            margin: 4px 0;
            border-top: 1px solid black;
            border-bottom: 1px solid black;
        }

        section table thead th {
            border-bottom: 1px solid black;
            text-align: left;
            text-transform: uppercase;
        }

        section .summary {
            border-bottom: 1px solid black;
            margin-bottom: 4px;
            padding-bottom: 4px;
        }

        section .summary div {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        footer {
            text-align: center;
            text-transform: uppercase;
            padding-bottom: 4px;
            border-bottom: 1px solid black;
        }

        @media print {
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
                font-family: monospace;
            }

            .wrapper {
                width: 52mm;
                padding: 4px;
                overflow: hidden;
            }

            .pgBreak {
                page-break-after: always;
            }

            header {
                text-align: center;
                width: 90%;
                margin: 0 auto;
                margin-bottom: 8px;
            }

            header img {
                height: 60px;
            }

            header h1,
            header h2,
            header h3,
            header h4,
            header h5,
            header h6 {
                font-size: 16px;
            }

            header p {
                font-size: 12px;
            }

            section {
                width: 100%;
                font-size: 12px;
            }

            section h1,
            section h2,
            section h3,
            section h4,
            section h5,
            section h6 {
                font-size: 14px;
                text-align: center;
                margin-bottom: 4px;
            }

            section table {
                width: 100%;
                border-collapse: collapse;
                margin: 4px 0;
                border-top: 1px solid black;
                border-bottom: 1px solid black;
            }

            section table thead th {
                border-bottom: 1px solid black;
                text-align: left;
                text-transform: uppercase;
            }

            section .summary {
                border-bottom: 1px solid black;
                margin-bottom: 4px;
                padding-bottom: 4px;
            }

            section .summary div {
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            footer {
                text-align: center;
                text-transform: uppercase;
                padding-bottom: 4px;
                border-bottom: 1px solid black;
            }

        }
    </style>
    <title>POS RECIEPT</title>
</head>
''';
// <header>
//             <img src="./logo.jpg" alt="Logo">
//             <h4>Villa Toscana</h4>
//             <p>Nation Towers-The St. Regis Abu Dhabi-UAE</p>
//         </header>
  String url = await getOfflineData('url');
  String logo = await getOfflineData('logo');
  String name = await getOfflineData('outletname');
  String address = await getOfflineData('outletaddress');

  String header = '''
  
<body>
    <main class="wrapper">
        <header>
            <img src="https://$url$logo" alt="Logo">
           <h4>$name</h4>
             <p>$address</p>
        </header>
        <section>
            <h6>POS Invoice</h6>
            <div>
                <p>Inv.: ${data.invoiceNo}</p>
                <p>Date: ${data.date}</p>
               
                <p>Tr. mode: ${data.paytype}</p>
            </div>
            ''';
  String tableHead = '''
            <table>
                <thead>
                    <tr>
                        <th>item</th>
                        <th>qty</th>
                        <th>total(INR)</th>
                    </tr>
                </thead>
                <tbody>''';
  String tableBody = '';
  for (OrderProduct res in data.productList) {
    tableBody += '''
                    <tr>
                        <td>${res.name}</td>
                        <td>${res.quantity}</td>
                        <td>${res.total}</td>
                    </tr>
                  
                    ''';
  }

  String tablefoot = '''
                </tbody>
            </table>
            ''';
  String table = tableHead + tableBody + tablefoot;
  String total = '''
            <div class="summary">
                <div>
                    <p>Subtotal:</p>
                    <p>${data.subtotal} INR</p>
                </div>
                <div>
                    <P>VAT :</P>
                    <p>${data.vat} INR</p>
                </div>
                <div>
                    <p>Discount @ 10%:</p>
                    <p>${data.discount} INR</p>
                </div>
            </div>
            <div class="summary">
                <div>
                    <p>Net total:</p>
                    <p>${data.total} INR</p>
                </div>
               
                <div>
                    <p>Total items:</p>
                    <p>${data.productList.length}</p>
                </div>
            </div>
        </section>
        ''';
  String foot = await getOfflineData("footer");
  String footer = '''
        <footer>
            <p>thank you</p>
            <p>$foot</p>
        </footer>
    </main>

    
</body>

</html>''';
  String dim = css + header + table + total + footer;
  return dim;
}

import 'package:agri_store/ui/Debts/AllDebt/client_details/client_debt/client_debt_details.dart';
import 'package:flutter/material.dart';
import '../../../data/model/client_invoice_model/debt_model.dart';

class DebtItem extends StatelessWidget {
  DebtModel debtModel;
  String uId;
  DebtItem({required this.debtModel,required this.uId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Center(
                    child: Text(
                      "${debtModel.oldDebt?.round().toString()}",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
              Expanded(flex: 1, child: Center(child: VerticalDivider())),

              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ClientDebtDetails(
                                debtModel: debtModel,
                                uId: uId ?? "",
                              ),
                        ),
                      );
                    },
                    child: Text(
                      "${debtModel.clientName}",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Divider(),
      ],
    );
  }
}

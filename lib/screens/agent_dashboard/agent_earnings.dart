import 'package:flexiphones/extensions/value_formating.dart';
import 'package:flexiphones/extensions/value_validation.dart';
import 'package:flexiphones/models/agent_m.dart';
import 'package:flexiphones/provider/provider_class.dart';
import 'package:flexiphones/shared_widgets/generalwidgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const _agentDark1 = Color(0xFF120A06);
const _agentDark2 = Color(0xFF3B2011);
const _agentGold = Color(0xFFCC9A44);

String agentMoney(double v) => "₵${v.toCommaSeparated(0, decimalPlaces: 2)}";

/// Real data from GET /partner/wallet, /partner/wallet/transactions and
/// /partner/momo-details. (The backend has no withdraw endpoint, so there
/// is no withdraw button — payouts go to the saved MoMo number.)
class AgentEarnings extends StatelessWidget {
  const AgentEarnings({super.key});

  @override
  Widget build(BuildContext context) {
    var ch = Theme.of(context).colorScheme;
    final p = Provider.of<SharedProvider>(context);
    final w = p.partnerWallet;
    final e = p.partnerEarnings;
    final momo = p.momoDetails;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: p.refreshAgentData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            Text(
              "Earnings",
              style: ptstyle(size: 20, weight: 700, color: ch.onSurface),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_agentDark2, _agentDark1],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "WALLET BALANCE",
                    style: ptstyle(
                      size: 10,
                      weight: 700,
                      color: Colors.white.withOpacity(0.6),
                    ).copyWith(letterSpacing: 2),
                  ),
                  SizedBox(height: 6),
                  Text(
                    w == null ? "—" : agentMoney(w.balance),
                    style: ptstyle(size: 30, weight: 700, color: Colors.white),
                  ),
                  SizedBox(height: 14),
                  Divider(color: Colors.white.withOpacity(0.1)),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Stat(
                        label: "TOTAL CREDITS",
                        value: w == null ? "—" : agentMoney(w.totalCredits),
                      ),
                      _Stat(
                        label: "TOTAL DEBITS",
                        value: w == null ? "—" : agentMoney(w.totalDebits),
                        valueColor: _agentGold,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (e != null) ...[
              SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: ch.onSurfaceVariant.withOpacity(0.15),
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "How you earn",
                      style: ptstyle(size: 13, weight: 700, color: ch.onSurface),
                    ),
                    SizedBox(height: 4),
                    Text(
                      e.ratesSentence,
                      style: ptstyle(
                        size: 11,
                        weight: 400,
                        color: ch.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 10),
                    _earnedRow(
                      ch,
                      "Down payment commission",
                      agentMoney(e.earnedDownPayment),
                    ),
                    _earnedRow(
                      ch,
                      "Repayment commission",
                      agentMoney(e.earnedRepayment),
                    ),
                    _earnedRow(ch, "Customers referred", "${e.referredCustomers}"),
                  ],
                ),
              ),
            ],
            SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: ch.onSurfaceVariant.withOpacity(0.15)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _agentGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.phone_android_rounded,
                      color: _agentGold,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "MoMo payout details",
                          style: ptstyle(
                            size: 13,
                            weight: 600,
                            color: ch.onSurface,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          (momo?.isSet ?? false)
                              ? "${momo!.network} · ${momo.number}\n${momo.accountName ?? ""}${momo.verified ? " · Verified" : " · Not verified yet"}"
                              : "Not set yet",
                          style: ptstyle(
                            size: 11,
                            weight: 300,
                            color: ch.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => MomoDialog(current: momo),
                    ),
                    child: Text(
                      (momo?.isSet ?? false) ? "Edit" : "Add",
                      style: ptstyle(size: 12, weight: 700, color: ch.primary),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 22),
            Text(
              "Transactions",
              style: ptstyle(size: 14, weight: 700, color: ch.onSurface),
            ),
            SizedBox(height: 8),
            if (p.partnerTransactions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text(
                    p.loadingTx
                        ? "Loading..."
                        : "No transactions yet. Commissions appear here.",
                    style: ptstyle(
                      size: 12,
                      weight: 300,
                      color: ch.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...p.partnerTransactions.map((t) => AgentTxRow(tx: t)),
            if (p.txHasMore)
              Center(
                child: TextButton(
                  onPressed: p.loadingTx
                      ? null
                      : () => p.getPartnerTransactions(refresh: false),
                  child: Text(
                    p.loadingTx ? "Loading..." : "Load more",
                    style: ptstyle(size: 12, weight: 600, color: ch.primary),
                  ),
                ),
              ),
            SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Points",
                    style: ptstyle(size: 14, weight: 700, color: ch.onSurface),
                  ),
                ),
                Text(
                  "${e?.points ?? 0} pts",
                  style: ptstyle(size: 14, weight: 700, color: _agentGold),
                ),
              ],
            ),
            Text(
              "Points are a score for now; they can't be spent yet.",
              style: ptstyle(size: 11, weight: 300, color: ch.onSurfaceVariant),
            ),
            SizedBox(height: 8),
            if (p.pointsHistory.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    p.loadingPoints
                        ? "Loading..."
                        : "No points yet. Share your promo code to earn some.",
                    style: ptstyle(
                      size: 12,
                      weight: 300,
                      color: ch.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...p.pointsHistory.map((pt) => _PointsRow(entry: pt)),
            if (p.pointsHasMore)
              Center(
                child: TextButton(
                  onPressed:
                      p.loadingPoints
                          ? null
                          : () => p.getPartnerPoints(refresh: false),
                  child: Text(
                    p.loadingPoints ? "Loading..." : "Load more",
                    style: ptstyle(size: 12, weight: 600, color: ch.primary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _earnedRow(ColorScheme ch, String label, String value) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: ptstyle(size: 12, weight: 400, color: ch.onSurfaceVariant),
        ),
        Text(value, style: ptstyle(size: 12, weight: 700, color: ch.onSurface)),
      ],
    ),
  );
}

class _PointsRow extends StatelessWidget {
  const _PointsRow({required this.entry});
  final PointsEntry entry;

  @override
  Widget build(BuildContext context) {
    var ch = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _agentGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.stars_rounded, size: 18, color: _agentGold),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ptstyle(size: 13, weight: 600, color: ch.onSurface),
                ),
                Text(
                  entry.createdAt.formatDateNoTime(),
                  style: ptstyle(
                    size: 11,
                    weight: 300,
                    color: ch.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "+${entry.points}",
            style: ptstyle(size: 13, weight: 700, color: _agentGold),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ptstyle(
            size: 10,
            weight: 600,
            color: Colors.white.withOpacity(0.5),
          ).copyWith(letterSpacing: 1),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: ptstyle(
            size: 16,
            weight: 700,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}

/// One wallet transaction row (used here and on the dashboard).
class AgentTxRow extends StatelessWidget {
  const AgentTxRow({super.key, required this.tx});
  final WalletTransaction tx;

  @override
  Widget build(BuildContext context) {
    var ch = Theme.of(context).colorScheme;
    final credit = tx.isCredit;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ch.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              credit ? Icons.south_west_rounded : Icons.north_east_rounded,
              size: 18,
              color: credit ? Colors.green : Colors.redAccent,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ptstyle(size: 13, weight: 600, color: ch.onSurface),
                ),
                Text(
                  [
                    tx.createdAt.formatDateNoTime(),
                    if (tx.kindLabel != null) tx.kindLabel!,
                    if (tx.status.isNotEmpty) tx.status,
                  ].join(" · "),
                  style: ptstyle(
                    size: 11,
                    weight: 300,
                    color: ch.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${credit ? "+" : "-"}${agentMoney(tx.amount)}",
            style: ptstyle(
              size: 13,
              weight: 700,
              color: credit ? Colors.green : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}

/// Add/edit MoMo payout details. Networks must match the backend enum
/// exactly: MTN | Vodafone | AirtelTigo.
class MomoDialog extends StatefulWidget {
  const MomoDialog({super.key, this.current});
  final MomoDetails? current;

  @override
  State<MomoDialog> createState() => _MomoDialogState();
}

class _MomoDialogState extends State<MomoDialog> {
  static const _networks = ["MTN", "Vodafone", "AirtelTigo"];
  late String network;
  late final TextEditingController number;
  late final TextEditingController name;
  String? error;

  @override
  void initState() {
    super.initState();
    final c = widget.current;
    network = _networks.contains(c?.network) ? c!.network! : "MTN";
    final digits = (c?.number ?? "").replaceAll(RegExp(r'[^0-9]'), '');
    number = TextEditingController(
      text: digits.length >= 9 ? digits.substring(digits.length - 9) : "",
    );
    name = TextEditingController(text: c?.accountName ?? "");
  }

  @override
  void dispose() {
    number.dispose();
    name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final n = number.text.trim();
    if (!n.isValidPartnerLocalPhone) {
      setState(() => error = "Enter 9 digits excluding the first 0");
      return;
    }
    if (name.text.trim().length < 2) {
      setState(() => error = "Enter the account name");
      return;
    }
    setState(() => error = null);
    final p = Provider.of<SharedProvider>(context, listen: false);
    final ok = await p.saveMomoDetails(
      context,
      network: network,
      localNumber: n,
      accountName: name.text,
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    var ch = Theme.of(context).colorScheme;
    final saving = Provider.of<SharedProvider>(context).savingMomo;
    return AlertDialog(
      backgroundColor: ch.surface,
      title: Text(
        "MoMo payout details",
        style: ptstyle(size: 16, weight: 600, color: ch.onSurface),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: network,
            decoration: const InputDecoration(labelText: "Network"),
            items: _networks
                .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                .toList(),
            onChanged: saving ? null : (v) => setState(() => network = v!),
          ),
          SizedBox(height: 10),
          TextField(
            controller: number,
            enabled: !saving,
            maxLength: 9,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: "MoMo number",
              prefixText: "0 ",
              counterText: "",
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: name,
            enabled: !saving,
            decoration: const InputDecoration(labelText: "Account name"),
          ),
          if (error != null) ...[
            SizedBox(height: 8),
            Text(
              error!,
              style: ptstyle(size: 11, weight: 400, color: Colors.redAccent),
            ),
          ],
          SizedBox(height: 8),
          Text(
            "Changing the network or number resets verification.",
            style: ptstyle(size: 11, weight: 300, color: ch.onSurfaceVariant),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        saving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton(onPressed: _save, child: const Text("Save")),
      ],
    );
  }
}
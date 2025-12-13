import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../widgets/step_indicator.dart';
import '../widgets/custom_input.dart';
import '../utils/validators.dart';

class FormMahasiswaScreen extends StatefulWidget {
  const FormMahasiswaScreen({super.key});

  @override
  State<FormMahasiswaScreen> createState() => _FormMahasiswaScreenState();
}

class _FormMahasiswaScreenState extends State<FormMahasiswaScreen> {
  int step = 0;

  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();

  final nama = TextEditingController();
  final email = TextEditingController();
  final hp = TextEditingController();

  String? jurusan;
  double semester = 1;
  bool setuju = false;
  List<String> hobi = [];

  final List<String> hobiList = [
    'Membaca',
    'Olahraga',
    'Musik',
    'Traveling'
  ];

  void next() {
    if (step == 0 && formKey1.currentState!.validate()) {
      setState(() => step++);
    } else if (step == 1 && formKey2.currentState!.validate()) {
      setState(() => step++);
    } else if (step == 2) {
      if (hobi.isEmpty || !setuju) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lengkapi hobi & persetujuan')),
        );
      } else {
        submit();
      }
    }
  }

  void submit() {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Berhasil 🎉'),
        content: Text('Data mahasiswa berhasil dikirim'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff667eea), Color(0xff764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Form Mahasiswa',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                StepIndicator(currentStep: step, totalStep: 3),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: GlassCard(
                      child: Column(
                        children: [
                          if (step == 0)
                            Form(
                              key: formKey1,
                              child: Column(
                                children: [
                                  CustomInput(
                                    controller: nama,
                                    label: 'Nama',
                                    icon: Icons.person,
                                    validator: Validators.required,
                                  ),
                                  const SizedBox(height: 16),
                                  CustomInput(
                                    controller: email,
                                    label: 'Email',
                                    icon: Icons.email,
                                    validator: Validators.email,
                                  ),
                                  const SizedBox(height: 16),
                                  CustomInput(
                                    controller: hp,
                                    label: 'Nomor HP',
                                    icon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                    validator: Validators.required,
                                  ),
                                ],
                              ),
                            ),

                          if (step == 1)
                            Form(
                              key: formKey2,
                              child: Column(
                                children: [
                                  DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      labelText: 'Jurusan',
                                      prefixIcon: Icon(Icons.school),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'Informatika',
                                          child: Text('Informatika')),
                                      DropdownMenuItem(
                                          value: 'Sistem Informasi',
                                          child:
                                              Text('Sistem Informasi')),
                                      DropdownMenuItem(
                                          value: 'Manajemen',
                                          child: Text('Manajemen')),
                                    ],
                                    validator: (v) =>
                                        v == null ? 'Pilih jurusan' : null,
                                    onChanged: (v) => jurusan = v,
                                  ),
                                  const SizedBox(height: 20),
                                  Text('Semester ${semester.toInt()}'),
                                  Slider(
                                    value: semester,
                                    min: 1,
                                    max: 8,
                                    divisions: 7,
                                    onChanged: (v) =>
                                        setState(() => semester = v),
                                  ),
                                ],
                              ),
                            ),

                          if (step == 2)
                            Column(
                              children: [
                                ...hobiList.map((h) => CheckboxListTile(
                                      title: Text(h),
                                      value: hobi.contains(h),
                                      onChanged: (v) {
                                        setState(() {
                                          v!
                                              ? hobi.add(h)
                                              : hobi.remove(h);
                                        });
                                      },
                                    )),
                                SwitchListTile(
                                  title: const Text(
                                      'Saya menyetujui data'),
                                  value: setuju,
                                  onChanged: (v) =>
                                      setState(() => setuju = v),
                                ),
                              ],
                            ),

                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: next,
                              child: Text(
                                  step == 2 ? 'KIRIM' : 'LANJUT'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

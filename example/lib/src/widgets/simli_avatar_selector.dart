import 'package:cached_network_image/cached_network_image.dart';
import 'package:deepgram_sdk/models/tts_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

Map<String, String> characterIds = {
  // "George": "04d062bc-00ce-4bb0-ace9-76880e3987ec",
  // "Cyborg": "101bef0d-b62d-4fbe-a6b4-89bc3fc66ec6",
  // "Aunt_Mimi": "11c30c18-86c3-424e-bb29-9c6d1fd6003b",
  // "Alex_1": "148efaa3-0224-490d-ab77-2a026f4e6738",
  // "Tesla_Vintage": "4145d354-fd78-4c29-b6b1-0663a04e8d7b",
  // "Alex_2": "45687133-5125-4070-b9ec-f5ffbeb6de0b",
  "Jenna": "tmp9i8bbq7c",
  "Franco": "5514e24d-6086-46a3-ace4-6a7264e5cb7c",
  // "Karen": "712469f7-a738-4a91-9a40-8c73144da4be",
  // "Sam_1": "743a34ba-435e-4c38-ac2b-c8b91d58a07e",
  // "Charlie": "802ee926-6318-481b-afd7-c74ef185c8b4",
  // "GigaKaren": "8f9d983d-c4bc-4bb1-8ee9-9269dfd6d5cb",
  // "Robot": "90730ca4-30e6-41e5-bf87-22b5fa8316eb",
  // "Tesla": "95708b15-bcb8-4d40-a4c5-b233778858b4",
  // "Lincoln": "9f3a3361-41b4-4157-87e6-9e6e4557ca7f",
  // "Munch": "ba81f852-e2ac-4d66-8e1e-584ce058b2af",
  // "Napoleon": "ba83c375-3720-44b8-a842-b0d188ecd099",
  // "Doctor": "cc0ca84d-d537-432e-b22e-348f0014aa49",
  // "Sam_2": "e279cc3c-cbc4-47af-8d45-eb34eb443f3e",
  // "GranKaren": "e7db6d91-4f46-40c8-b8bc-b284aa2989a6",

  "Aera": "cc2cece4-3fff-4469-9964-5d543d2e28db",
};

DeepgramTtsModel? getTtsModel(String faceId) {
  var models = {
    "tmp9i8bbq7c": DeepgramTtsModel.asteria,
    "5514e24d-6086-46a3-ace4-6a7264e5cb7c": DeepgramTtsModel.arcas,
    "cc2cece4-3fff-4469-9964-5d543d2e28db": DeepgramTtsModel.luna,
  };
  return models[faceId];
}

class SimliAvatarSelector extends StatelessWidget {
  const SimliAvatarSelector(
      {super.key,
      this.scrollDirection = Axis.vertical,
      required this.onSelect});
  final Axis scrollDirection;
  final Function(String faceID) onSelect;
  @override
  Widget build(BuildContext context) {
    var names = characterIds.keys.toList();
    var ids = characterIds.values.toList();
    return Container(
      height: 256,
      margin: const EdgeInsets.only(left: 0, top: 8, right: 8, bottom: 8),
      child: ListView.separated(
        scrollDirection: scrollDirection,
        itemBuilder: (context, index) => _SimliAvatarView(
          name: names[index].toString(),
          onSelect: () {
            onSelect(ids[index]);
          },
        ),
        itemCount: names.length,
        separatorBuilder: (context, index) => const Gap(8),
      ),
    );
  }
}

class _SimliAvatarView extends StatefulWidget {
  const _SimliAvatarView({required this.name, this.onSelect});
  final String name;
  final VoidCallback? onSelect;
  @override
  State<_SimliAvatarView> createState() => _SimliAvatarViewState();
}

class _SimliAvatarViewState extends State<_SimliAvatarView> {
  bool hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) {
        setState(() {
          hovered = true;
        });
      },
      onExit: (event) {
        setState(() {
          hovered = false;
        });
      },
      child: SizedBox(
        width: 256,
        height: 256,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl:
                      'https://mintlify.s3-us-west-1.amazonaws.com/simli/${widget.name}.png',
                  width: 256,
                  height: 256,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
                child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                  color: hovered
                      ? Colors.black.withOpacity(0.55)
                      : Colors.transparent),
              child: hovered
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                        const Gap(16),
                        ElevatedButton(
                          onPressed: () {
                            widget.onSelect?.call();
                          },
                          child: const Text(
                            "Select",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        )
                      ],
                    )
                  : null,
            ))
          ],
        ),
      ),
    );
  }
}

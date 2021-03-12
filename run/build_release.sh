# Builds the kernel snapshot to run app in release mode.
# Should be run from the directory of the project.

/Users/matze/Development/SDKs/flutter_stable/bin/cache/dart-sdk/bin/dart \
    /Users/matze/Development/SDKs/flutter_stable/bin/cache/dart-sdk/bin/snapshots/frontend_server.dart.snapshot \
    --sdk-root /Users/matze/Development/SDKs/flutter_stable/bin/cache/artifacts/engine/common/flutter_patched_sdk_product \
    --target=flutter \
    --aot \
    --tfa \
    -Ddart.vm.product=true \
    --packages .packages \
    --output-dill build/kernel_snapshot.dill \
    --verbose \
    --depfile build/kernel_snapshot.d \
    package:kart_project/main.dart

sudo ./engine-binaries/arm/gen_snapshot_linux_x64_profile \
    --deterministic \
    --snapshot_kind=app-aot-elf \
    --elf=./flutter_assets/app.so \
    --strip \
    --sim-use-hardfp \
    ./kernel_snapshot.dill \
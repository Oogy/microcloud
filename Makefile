.PHONY: k0s-install k0s-uninstall k0s-gpu-test

k0s-install:
	@. scripts/k0s.sh && k0s_install

k0s-uninstall:
	@. scripts/k0s.sh && k0s_uninstall

k0s-gpu-test:
	@. scripts/k0s.sh && k0s_gpu_test

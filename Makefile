HOSTNAME != hostname -s
SITE=site75-${HOSTNAME}.tgz

help:
	@echo SITE=$(SITE)
	@echo "Targets:"
	@echo "  site  - create site set for installation"
	@echo "  patch - patch installation bsd.rd"

site: $(SITE)

clean:
	rm -f $(SITE)

$(SITE):
	tar -I site.index -c -z -f $(SITE)

PDIR=/tmp/patch
IMGDIR=/tmp/patch/img
RDDIR=/tmp/patch/rd

.PHONY: patch
patch:
	test ! -d $(PDIR)
	vnconfig -l vnd0 | grep -q 'not in use'
	mkdir -p $(PDIR) $(IMGDIR) $(RDDIR)
	mount /dev/sd1a $(IMGDIR)
	zcat $(IMGDIR)/bsd.rd > $(PDIR)/bsd.urd
	rdsetroot -x $(PDIR)/bsd.urd $(PDIR)/bsd.fs
	vnconfig vnd0 $(PDIR)/bsd.fs
	mount /dev/vnd0a $(RDDIR)
	cp install.resp $(RDDIR)/auto_install.conf
	cp disklabel $(RDDIR)/disklabel
	umount $(RDDIR)
	rdsetroot $(PDIR)/bsd.urd $(PDIR)/bsd.fs
	compress -9 < $(PDIR)/bsd.urd > $(IMGDIR)/bsd.rd
	echo "set image /bsd.rd" > $(IMGDIR)/etc/boot.conf
	mkdir -p $(IMGDIR)/patch
	cp Makefile install.resp disklabel site.index $(IMGDIR)/patch/
	umount $(IMGDIR)
	$(MAKE) patch-clean
	@echo "completed"

patch-clean:
	@echo "unmount installation media"
	@mount | ! grep -q $(RDDIR) || umount $(RDDIR)
	@mount | ! grep -q $(IMGDIR) || umount $(IMGDIR)
	@vnconfig -l vnd0 | grep -q 'not in use' || vnconfig -u vnd0
	@echo "remove temporary files"
	@test ! -d $(IMGDIR) || rmdir $(IMGDIR)
	@test ! -d $(RDDIR) || rmdir $(RDDIR)
	@test ! -d $(PDIR) || rm -rf $(PDIR)

#include <stdio.h>
#ifdef WIN32
#include <wtypes.h>
#else
#include <wchar.h>
#include <stdint.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#endif

struct LinkedMem {
#ifdef WIN32
	UINT32	uiVersion;
	DWORD	uiTick;
#else
	uint32_t uiVersion;
	uint32_t uiTick;
#endif
	float	fAvatarPosition[3];
	float	fAvatarFront[3];
	float	fAvatarTop[3];
	wchar_t	name[256];
	float	fCameraPosition[3];
	float	fCameraFront[3];
	float	fCameraTop[3];
	wchar_t	identity[256];
#ifdef WIN32
	UINT32	context_len;
#else
	uint32_t context_len;
#endif
	unsigned char context[256];
	wchar_t description[2048];
};
typedef struct LinkedMem LinkedMem;

LinkedMem *lm = NULL;

void testStuff( wchar_t* test ) {
	wprintf(L"String is \"%lS\"\n", test);
	wprintf(L"Allocated length is %d bytes\n", sizeof(test));
	//free(test);
}

int initMumble_C() {

#ifdef WIN32
	HANDLE hMapObject = OpenFileMappingW(FILE_MAP_ALL_ACCESS, FALSE, L"MumbleLink");
	if (hMapObject == NULL)
		return 0;

	lm = (LinkedMem *) MapViewOfFile(hMapObject, FILE_MAP_ALL_ACCESS, 0, 0, sizeof(LinkedMem));
	if (lm == NULL) {
		CloseHandle(hMapObject);
		hMapObject = NULL;
		return 0;
	}
#else
	char memname[256];
	snprintf(memname, 256, "/MumbleLink.%d", getuid());

	int shmfd = shm_open(memname, O_RDWR, S_IRUSR | S_IWUSR);

	if (shmfd < 0) {
		return 0;
	}

	lm = (LinkedMem *)(mmap(NULL, sizeof(struct LinkedMem), PROT_READ | PROT_WRITE, MAP_SHARED, shmfd,0));

	if (lm == (void *)(-1)) {
		lm = NULL;
		return 0;
	}
#endif
    return 1;
}
void setPluginInfo_C( wchar_t *name, wchar_t *description ) {
	if(lm->uiVersion != 2) {
		wcsncpy(lm->name, name, 256);
		wcsncpy(lm->description, description, 2048);
		lm->uiVersion = 2;
	}
	//free(name);
	//free(description);
}

void setAvatarFront_C( float vx, float vy, float vz ) {
	lm->fAvatarFront[0] = vx;
	lm->fAvatarFront[1] = vy;
	lm->fAvatarFront[2] = vz;
}

void setAvatarTop_C( float vx, float vy, float vz ) {
	lm->fAvatarTop[0] = vx;
	lm->fAvatarTop[1] = vy;
	lm->fAvatarTop[2] = vz;
}

void setAvatarPosition_C( float x, float y, float z ) {
	lm->fAvatarPosition[0] = x;
	lm->fAvatarPosition[1] = y;
	lm->fAvatarPosition[2] = z;
}

void setCameraPosition_C( float x, float y, float z ) {
	lm->fCameraPosition[0] = x;
	lm->fCameraPosition[1] = y;
	lm->fCameraPosition[2] = z;
}

void setCameraFront_C( float vx, float vy, float vz ) {
	lm->fCameraFront[0] = vx;
	lm->fCameraFront[1] = vy;
	lm->fCameraFront[2] = vz;
}

void setCameraTop_C( float vx, float vy, float vz ) {
	lm->fCameraTop[0] = vx;
	lm->fCameraTop[1] = vy;
	lm->fCameraTop[2] = vz;
}

void setPlayerIdentity_C( wchar_t* identity ) {
	wcsncpy(lm->identity, identity, 256);
	//free(identity);
}

void setPlayerContext_C( wchar_t* context ) {
	memcpy(lm->context, context, sizeof(context));
	lm->context_len = sizeof(context);
	//free(context);
}

void updateMumble_C() {
	if (! lm)
		return;

	/* if(lm->uiVersion != 2) {
		wcsncpy(lm->name, L"TestLink", 256);
		wcsncpy(lm->description, L"TestLink is a test of the Link plugin.", 2048);
		lm->uiVersion = 2;
	} */
	lm->uiTick++;

	// Left handed coordinate system.
	// X positive towards "left".
	// Y positive towards "up".
	// Z positive towards "into screen".
	//
	// 1 unit = 1 meter
	
	// Context should be equal for players which should be able to hear each other positional and
	// differ for those who shouldn't (e.g. it could contain the server+port and team)
	// memcpy(lm->context, "ContextBlob\x00\x01\x02\x03\x04", 16);
	// lm->context_len = 16;
}

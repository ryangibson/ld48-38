//import SDL2

// TODO: createTexture() - proper enums for access, format
// TODO: isClipEnabled() - undefined?
// TODO: SDL_SetRenderTarget(), SDL_GetRenderTarget()
//	- need a way to map between SDL pointers and Swift classes
//    (just stash the current render target on the class instance?)
// TOOD: SDL_RenderCopyEx() - need to decide best way to deal with params
// TODO: SDL_RenderReadPixels() - extend to support raw arrays?
// TODO: SDL_RendererInfo - retrieve flags, texture formats

// TODO: blend mode stuff - need enums/wrapper
//	- SDL_GetRenderDrawBlendMode
//  - SDL_SetRenderDrawBlendMode

// ---
// TODO: SDL_GetNumRenderDrivers() - create wrapper struct for SDL_RendererInfo and add a static method Renderer.enumerateDrivers to return an array using SDL_GetRenderDriverInfo()
// TODO: SDL_GL_BindTexture, SDL_GL_UnbindTexture - postponed until we tackle OpenGL
// TODO: SDL_UpdateYUVTexture()

public class Renderer {
	init(renderer: OpaquePointer) {
		theRenderer = renderer
		theInfo = SDL_RendererInfo()
		SDL_GetRendererInfo(theRenderer, &theInfo)
	}

	deinit {
		SDL_DestroyRenderer(theRenderer)
	}

	public func _sdlRenderer() -> OpaquePointer {
		return theRenderer
	}

	public var name : String {
		get { return String(cString: theInfo.name) }
	}

	public var numberOfTextureFormats : Int {
		get { return Int(theInfo.num_texture_formats) }
	}

	public var maxTextureWidth : Int {
		get { return Int(theInfo.max_texture_width) }
	}

	public var maxTextureHeight : Int {
		get { return Int(theInfo.max_texture_height) }
	}

	public var renderTargetSupported : Bool {
		get { return SDL_RenderTargetSupported(theRenderer) == SDL_TRUE }
	}

	public func copyOutputSizeTo(x: inout Int, y: inout Int) {
		var x32: Int32 = 0, y32: Int32 = 0
		SDL_GetRendererOutputSize(theRenderer, &x32, &y32)
		x = Int(x32)
		y = Int(y32)
	}

	public func copyLogicalSizeTo(x: inout Int, y: inout Int) {
		var x32: Int32 = 0, y32: Int32 = 0
		SDL_RenderGetLogicalSize(theRenderer, &x32, &y32)
		x = Int(x32)
		y = Int(y32)
	}

	public func setLogicalSize(x: Int, _ y: Int) {
		SDL_RenderSetLogicalSize(theRenderer, Int32(x), Int32(y))
	}

	//public func isClipEnabled() -> Bool {
	//	return SDL_RenderIsClipEnabled(theRenderer) == 1
	//}

	public func setClipRect(rect: inout Rect) {
		SDL_RenderSetClipRect(theRenderer, &rect)
	}

	public func copyClipRectTo(rect: inout Rect) {
		SDL_RenderGetClipRect(theRenderer, &rect)
	}

	public func setScale(scale: Float) {
		SDL_RenderSetScale(theRenderer, scale, scale)
	}

	public func setScale(sx: Float, _ sy: Float) {
		SDL_RenderSetScale(theRenderer, sx, sy)	
	}

	public func copyScaleTo(sx: inout Float,  _ sy: inout Float) {
		SDL_RenderGetScale(theRenderer, &sx, &sy)	
	}

	public func copyViewportTo(rect: inout Rect) {
		SDL_RenderGetViewport(theRenderer, &rect)
	}

	public func setViewport(rect: Rect) {
		var r = rect
		SDL_RenderSetViewport(theRenderer, &r)
	}

	public func setViewport(rect: inout Rect) {
		SDL_RenderSetViewport(theRenderer, &rect)
	}

	public func clear() {
		SDL_RenderClear(theRenderer)
	}

	public func present() {
		SDL_RenderPresent(theRenderer)
	}

	public func createTexture(format: UInt32, access: Int, width: Int, height: Int) -> Texture {
    	let tex = SDL_CreateTexture(theRenderer, format, Int32(access), Int32(width), Int32(height))
    	return Texture(sdlTexture: tex!)
    }

	public func createTextureFromSurface(surface: Surface) -> Texture {
		let tex = SDL_CreateTextureFromSurface(theRenderer, surface._sdlSurface())
		return Texture(sdlTexture: tex!)
	}

	public func createStreamingTexture(width: Int, height: Int) -> Texture {
		let tex = SDL_CreateTexture(
			theRenderer,
			Uint32(SDL_PIXELFORMAT_ARGB8888),
			Int32(SDL_TEXTUREACCESS_STREAMING),
			Int32(width),
			Int32(height)
		)
		return Texture(sdlTexture: tex!)
	}

	public func copyDrawColorTo(r: inout UInt8, g: inout UInt8, b: inout UInt8, a: inout UInt8) {
		SDL_GetRenderDrawColor(theRenderer, &r, &g, &b, &a)
	}

	public func setDrawColor(r: Uint8, g: Uint8, b: Uint8, a: Uint8 = 255) {
		SDL_SetRenderDrawColor(theRenderer, r, g, b, a)
	}

	public func copyTexture(texture: Texture) {
		SDL_RenderCopy(theRenderer, texture._sdlTexture(), nil, nil)
	}

	public func copyTexture(texture: Texture, sourceRect: Rect, destinationRect: Rect) {
		var s = sourceRect, d = destinationRect
		SDL_RenderCopy(theRenderer, texture._sdlTexture(), &s, &d)
	}

	public func copyTexture(texture: Texture,  sourceRect s: inout Rect,  destinationRect d: inout Rect) {
		SDL_RenderCopy(theRenderer, texture._sdlTexture(), &s, &d)
	}

	public func copyTexture(texture: Texture,  sourceRect s: inout Rect) {
		SDL_RenderCopy(theRenderer, texture._sdlTexture(), &s, nil)
	}

	public func copyTexture(texture: Texture, sourceRect: Rect) {
		var s = sourceRect
		SDL_RenderCopy(theRenderer, texture._sdlTexture(), &s, nil)
	}

	public func copyTexture(texture: Texture,  destinationRect d: inout Rect) {
		SDL_RenderCopy(theRenderer, texture._sdlTexture(), nil, &d)
	}

	public func copyTexture(texture: Texture, destinationRect: Rect) {
		var d = destinationRect
		SDL_RenderCopy(theRenderer, texture._sdlTexture(), nil, &d)
	}

	//
	// Drawing

	public func drawLine(x1: Int, _ y1: Int, _ x2: Int, _ y2: Int) {
		SDL_RenderDrawLine(theRenderer, Int32(x1), Int32(y1), Int32(x2), Int32(y2))
	}

	public func drawLine(p1: Point, _ p2: Point) {
		SDL_RenderDrawLine(theRenderer, p1.x, p1.y, p2.x, p2.y)
	}

	public func drawLines(ps: [Point]) {
		SDL_RenderDrawLines(theRenderer, ps, Int32(ps.count))
	}

	public func drawPoint(x: Int, _ y: Int) {
		SDL_RenderDrawPoint(theRenderer, Int32(x), Int32(y))
	}

	public func drawPoint(p: Point) {
		SDL_RenderDrawPoint(theRenderer, p.x, p.y)
	}

	public func drawPoints(ps: [Point]) {
		SDL_RenderDrawPoints(theRenderer, ps, Int32(ps.count))
	}

	public func drawRect(rect: inout Rect) {
		SDL_RenderDrawRect(theRenderer, &rect)
	}

	public func drawRect(rect: Rect) {
		var r = rect
		SDL_RenderDrawRect(theRenderer, &r)
	}

	public func drawRects(rects: [Rect]) {
		SDL_RenderDrawRects(theRenderer, rects, Int32(rects.count))
	}

	public func fillRect(rect: inout Rect) {
		SDL_RenderFillRect(theRenderer, &rect)
	}

	public func fillRect(rect: Rect) {
		var r = rect
		SDL_RenderFillRect(theRenderer, &r)
	}

	public func fillRects(rects: [Rect]) {
		SDL_RenderFillRects(theRenderer, rects, Int32(rects.count))
	}

	public func readPixelsToSurface(surface: Surface) {
		let sdlSurface = surface._sdlSurface()
		SDL_RenderReadPixels(
			theRenderer,
			nil,
			sdlSurface.pointee.format.pointee.format,
			sdlSurface.pointee.pixels,
			sdlSurface.pointee.pitch
		)
	}

	public func readPixelRect(rect: Rect, toSurface surface: Surface) {
		var r = rect
		let sdlSurface = surface._sdlSurface()
		SDL_RenderReadPixels(
			theRenderer,
			&r,
			sdlSurface.pointee.format.pointee.format,
			sdlSurface.pointee.pixels,
			sdlSurface.pointee.pitch
		)
	}

	let theRenderer: OpaquePointer
	var theInfo: SDL_RendererInfo
}

// TODO: SDL_CreateRenderer - support index, flags
public class WindowRenderer : Renderer {
	public init(window: Window) {
		theWindow = window
		super.init(renderer: SDL_CreateRenderer(window._sdlWindow(), -1, UInt32(0)))
	}

	let theWindow: Window
}

public class SoftwareRenderer : Renderer {
	public init(surface: Surface) {
		super.init(renderer: SDL_CreateSoftwareRenderer(surface._sdlSurface()))
	}
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.ComponentModel;
using System.Runtime.CompilerServices;

using OpenTK;
using OpenTK.Graphics.OpenGL4;
using OpenTK.Mathematics;
using OpenTK.Wpf;

using LinearAlgebra;

namespace CurvedMeshRenderer
{
    /// <summary>
    /// Interaction logic for RenderControl.xaml
    /// </summary>
    public partial class RenderControl : UserControl
    {
        public static readonly DependencyProperty CameraProperty;
        
        internal Camera Camera
        {
            get
            {
                return (Camera)GetValue(CameraProperty);
            }
            private set
            {
                SetValue(CameraProperty, value);
            }
        }
        private bool initialized = false;
        private readonly double ZoomDelta = 1.1;
        //private FrameBufferPool? FBP;
        private int dummyVAO;
        private FrameBuffer? FBO;

        #region click and drag control states
        private bool isMouseWheelDown = false;
        private LinearAlgebra.Vector2 mouseDragVirtualBase;
        #endregion

        static RenderControl()
        {
            CameraProperty = DependencyProperty.Register(nameof(Camera), typeof(Camera), typeof(RenderControl));
        }

        public RenderControl()
        {
            InitializeComponent();
            GLWpfControlSettings settings = new GLWpfControlSettings
            {
                MajorVersion = 4,
                MinorVersion = 0
            };
            OpenTKControl.Start(settings);

            GL.Disable(EnableCap.DepthTest);
            GL.Disable(EnableCap.StencilTest);
            GL.LineWidth(2);

            Focusable = true;
        }
        private void OpenTKControl_Loaded(object sender, RoutedEventArgs e)
        {
            Camera = new Camera((int)OpenTKControl.ActualWidth, (int)OpenTKControl.ActualHeight, 4);
            //FBP = new FrameBufferPool(8, Camera.ScreenWidth, Camera.ScreenHeight, TextureType.FloatValue);
            FBO = new FrameBuffer(new Texture2D(Camera.ScreenWidth, Camera.ScreenHeight), true);

            dummyVAO = GL.GenVertexArray();

            AssetsManager.LoadPipeline("QuadraticConcave", "Shaders\\quadraticConcave.vsh",
                                                           "Shaders\\quadraticConcave.gsh",
                                                           "Shaders\\quadraticConcave.fsh");
            AssetsManager.LoadPipeline("QuadraticConcaveBorder", "Shaders\\quadraticConcave.vsh",
                                                                 "Shaders\\quadraticConcaveBorder.gsh",
                                                                 "Shaders\\solidColor.fsh");
            AssetsManager.LoadPipeline("FullscreenTex", "Shaders\\fullscreenQuad.vsh",
                                                        "Shaders\\simpleTex.fsh");

            AssetsManager.LoadMesh("TestMesh", "mesh.obj");

            initialized = true;
        }
        private void OpenTKControl_Update(TimeSpan deltaTime)
        {
            if (!initialized)
                return;

            Mesh mesh = AssetsManager.Meshs["TestMesh"];
            renderMesh(deltaTime, mesh);
            renderMeshBorder(deltaTime, mesh);
        }
        private void renderMesh(TimeSpan deltaTime, Mesh mesh)
        {
            //FrameBuffer.UseDefault((int)OpenTKControl.ActualWidth, (int)OpenTKControl.ActualHeight);
            FBO!.Use();
            GL.ClearColor(1.0f, 1.0f, 1.0f, 1.0f);
            GL.Clear(ClearBufferMask.ColorBufferBit);

            Pipeline pipeline = AssetsManager.Pipelines["QuadraticConcave"];
            pipeline.Use();
            pipeline.UniformMatrix3x3("view", (Matrix3x3f)Camera.View);
            GL.BindVertexArray(mesh.VAO);

            GL.Enable(EnableCap.StencilTest);

            GL.Clear(ClearBufferMask.StencilBufferBit);
            GL.StencilFunc(StencilFunction.Always, 0, 1);
            GL.StencilOp(StencilOp.Invert, StencilOp.Invert, StencilOp.Invert);
            GL.ColorMask(false, false, false, false);
            
            GL.DrawElements(PrimitiveType.TrianglesAdjacency, 6 * mesh.Polygons.Count, DrawElementsType.UnsignedInt, 0);
            
            GL.StencilFunc(StencilFunction.Equal, 1, 1);
            GL.StencilOp(StencilOp.Keep, StencilOp.Keep, StencilOp.Keep);
            GL.ColorMask(true, true, true, true);

            GL.DrawElements(PrimitiveType.TrianglesAdjacency, 6 * mesh.Polygons.Count, DrawElementsType.UnsignedInt, 0);

            GL.Disable(EnableCap.StencilTest);

            FrameBuffer.UseDefault((int)OpenTKControl.ActualWidth, (int)OpenTKControl.ActualHeight);

            pipeline = AssetsManager.Pipelines["FullscreenTex"];
            pipeline.Use();

            FBO!.ColorTexture.Bind("tex");

            GL.BindVertexArray(dummyVAO);
            GL.DrawArrays(PrimitiveType.Triangles, 0, 6);
        }
        private void renderMeshBorder(TimeSpan deltatime, Mesh mesh)
        {
            FrameBuffer.UseDefault((int)OpenTKControl.ActualWidth, (int)OpenTKControl.ActualHeight);

            Pipeline pipeline = AssetsManager.Pipelines["QuadraticConcaveBorder"];
            pipeline.Use();
            pipeline.UniformMatrix3x3("view", (Matrix3x3f)Camera.View);
            pipeline.Uniform4("color", 0.0f, 0.0f, 0.0f, 1.0f);

            GL.BindVertexArray(mesh.VAO);
            GL.DrawElements(PrimitiveType.TrianglesAdjacency, 6 * mesh.Polygons.Count, DrawElementsType.UnsignedInt, 0);
        }
        private void UserControl_MouseWheel(object sender, MouseWheelEventArgs e)
        {
            e.Handled = true;

            Point position = e.GetPosition(this);
            LinearAlgebra.Vector2 point = Camera.ScreenToWorld(new LinearAlgebra.Vector2(position.X, position.Y));
            double delta = e.Delta > 0 ? this.ZoomDelta : 1 / this.ZoomDelta;

            Camera.Zoom(point, delta);
        }

        private void OpenTKControl_SizeChanged(object sender, SizeChangedEventArgs e)
        {
            if (!initialized)
                return;

            Camera.ScreenWidth = (int)e.NewSize.Width;
            Camera.ScreenHeight = (int)e.NewSize.Height;

            //FBP?.Dispose();
            //FBP = new FrameBufferPool(8, Camera.ScreenWidth, Camera.ScreenHeight, TextureType.FloatValue);
        }

        private void UserControl_MouseMove(object sender, MouseEventArgs e)
        {
            e.Handled = true;

            if (isMouseWheelDown)
            {
                Point mousePosPoint = e.GetPosition(this);
                Camera.Position += mouseDragVirtualBase - Camera.ScreenToWorld(new LinearAlgebra.Vector2(mousePosPoint.X, mousePosPoint.Y));
            }
        }
        private void UserControl_MouseDown(object sender, MouseButtonEventArgs e)
        {
            e.Handled = true;
            if (!IsFocused)
                Focus();

            if (e.ChangedButton == MouseButton.Middle)
            {
                isMouseWheelDown = true;
                Point mousePos = e.GetPosition(this);
                mouseDragVirtualBase = Camera.ScreenToWorld(new LinearAlgebra.Vector2(mousePos.X, mousePos.Y));
            }
        }
        private void UserControl_MouseUp(object sender, MouseButtonEventArgs e)
        {
            e.Handled = true;

            switch (e.ChangedButton)
            {
                case MouseButton.Middle:
                    isMouseWheelDown = false;
                    break;
            }
        }
        public void UserControl_KeyDown(object sender, KeyEventArgs e)
        {
            e.Handled = true;

        }
        public void UserControl_KeyUp(object sender, KeyEventArgs e)
        {
            e.Handled = true;
        }
    }
}

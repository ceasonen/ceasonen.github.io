/**
 * 交互式知识星云 - 主JavaScript文件
 * 使用Three.js创建3D粒子星云，GSAP处理动画，实现沉浸式交互体验
 */

// 全局变量
let scene, camera, renderer, controls;
let particleSystem, nodes = [];
let raycaster, mouse, isMouseDown = false;
let currentView = 'main'; // 当前视图状态
let animationId;
let isLoaded = false;

// 节点数据结构
const nodeData = {
    about: {
        title: '关于我',
        position: new THREE.Vector3(0, 0, -50),
        color: 0x00bfff,
        size: 2,
        template: 'about-template'
    },
    projects: {
        title: '项目作品',
        position: new THREE.Vector3(-30, 20, -40),
        color: 0xD4AF37,
        size: 1.8,
        template: 'project-template',
        subNodes: [
            { title: '3D作品集', position: new THREE.Vector3(-25, 25, -35), color: 0x00bfff, size: 0.8 },
            { title: '数据可视化', position: new THREE.Vector3(-35, 15, -35), color: 0x00bfff, size: 0.8 },
            { title: 'AI设计工具', position: new THREE.Vector3(-30, 10, -45), color: 0x00bfff, size: 0.8 }
        ]
    },
    articles: {
        title: '技术文章',
        position: new THREE.Vector3(30, -20, -40),
        color: 0xff6b6b,
        size: 1.8,
        template: 'article-template',
        subNodes: [
            { title: 'WebGL优化', position: new THREE.Vector3(25, -15, -35), color: 0xff6b6b, size: 0.8 },
            { title: 'CSS动画', position: new THREE.Vector3(35, -25, -35), color: 0xff6b6b, size: 0.8 },
            { title: '粒子系统', position: new THREE.Vector3(30, -30, -45), color: 0xff6b6b, size: 0.8 }
        ]
    },
    contact: {
        title: '联系我',
        position: new THREE.Vector3(0, -40, -30),
        color: 0x4ecdc4,
        size: 1.5,
        template: 'contact-template'
    }
};

// 初始化函数
function init() {
    console.log('初始化知识星云...');
    
    // 创建场景
    scene = new THREE.Scene();
    scene.background = new THREE.Color(0x050810);
    
    // 创建相机
    camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
    camera.position.set(0, 0, 50);
    
    // 创建渲染器
    const canvas = document.getElementById('bg');
    renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setPixelRatio(window.devicePixelRatio);
    
    // 设置渲染器属性
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1.2;
    
    // 创建光线
    setupLighting();
    
    // 创建粒子系统
    createParticleSystem();
    
    // 创建节点
    createNodes();
    
    // 设置交互
    setupInteraction();
    
    // 开始渲染循环
    animate();
    
    // 隐藏加载界面
    setTimeout(() => {
        hideLoading();
    }, 2000);
}

// 设置光照
function setupLighting() {
    // 环境光
    const ambientLight = new THREE.AmbientLight(0x404040, 0.3);
    scene.add(ambientLight);
    
    // 点光源
    const pointLight = new THREE.PointLight(0x00bfff, 1, 100);
    pointLight.position.set(0, 0, 0);
    scene.add(pointLight);
    
    // 方向光
    const directionalLight = new THREE.DirectionalLight(0xffffff, 0.5);
    directionalLight.position.set(10, 10, 5);
    directionalLight.castShadow = true;
    scene.add(directionalLight);
}

// 创建粒子系统
function createParticleSystem() {
    const particleCount = 2000;
    const positions = new Float32Array(particleCount * 3);
    const colors = new Float32Array(particleCount * 3);
    const sizes = new Float32Array(particleCount);
    
    // 创建粒子几何体
    const geometry = new THREE.BufferGeometry();
    
    // 随机生成粒子位置
    for (let i = 0; i < particleCount; i++) {
        const i3 = i * 3;
        
        // 在球形区域内随机分布
        const radius = Math.random() * 200 + 50;
        const theta = Math.random() * Math.PI * 2;
        const phi = Math.acos(2 * Math.random() - 1);
        
        positions[i3] = radius * Math.sin(phi) * Math.cos(theta);
        positions[i3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
        positions[i3 + 2] = radius * Math.cos(phi);
        
        // 设置颜色（白色到淡蓝色渐变）
        const colorIntensity = Math.random() * 0.5 + 0.5;
        colors[i3] = colorIntensity;
        colors[i3 + 1] = colorIntensity;
        colors[i3 + 2] = colorIntensity;
        
        // 设置大小
        sizes[i] = Math.random() * 2 + 1;
    }
    
    geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
    geometry.setAttribute('size', new THREE.BufferAttribute(sizes, 1));
    
    // 创建粒子材质
    const material = new THREE.PointsMaterial({
        size: 2,
        vertexColors: true,
        transparent: true,
        opacity: 0.8,
        blending: THREE.AdditiveBlending
    });
    
    // 创建粒子系统
    particleSystem = new THREE.Points(geometry, material);
    scene.add(particleSystem);
    
    // 添加旋转动画
    gsap.to(particleSystem.rotation, {
        y: Math.PI * 2,
        duration: 100,
        ease: "none",
        repeat: -1
    });
}

// 创建节点
function createNodes() {
    Object.keys(nodeData).forEach(key => {
        const data = nodeData[key];
        const node = createNode(data);
        nodes.push(node);
        scene.add(node);
        
        // 创建子节点
        if (data.subNodes) {
            data.subNodes.forEach(subData => {
                const subNode = createNode(subData);
                subNode.visible = false; // 初始隐藏子节点
                nodes.push(subNode);
                scene.add(subNode);
            });
        }
    });
}

// 创建单个节点
function createNode(data) {
    const geometry = new THREE.SphereGeometry(data.size, 16, 16);
    const material = new THREE.MeshPhongMaterial({
        color: data.color,
        emissive: data.color,
        emissiveIntensity: 0.3,
        transparent: true,
        opacity: 0.9
    });
    
    const node = new THREE.Mesh(geometry, material);
    node.position.copy(data.position);
    node.userData = data;
    
    // 添加发光效果
    const glowGeometry = new THREE.SphereGeometry(data.size * 1.5, 16, 16);
    const glowMaterial = new THREE.MeshBasicMaterial({
        color: data.color,
        transparent: true,
        opacity: 0.2,
        side: THREE.BackSide
    });
    const glow = new THREE.Mesh(glowGeometry, glowMaterial);
    node.add(glow);
    
    // 添加脉冲动画
    gsap.to(node.scale, {
        x: 1.2,
        y: 1.2,
        z: 1.2,
        duration: 2,
        ease: "power2.inOut",
        yoyo: true,
        repeat: -1
    });
    
    return node;
}

// 设置交互
function setupInteraction() {
    raycaster = new THREE.Raycaster();
    mouse = new THREE.Vector2();
    
    // 鼠标移动事件
    window.addEventListener('mousemove', onMouseMove);
    window.addEventListener('mousedown', onMouseDown);
    window.addEventListener('mouseup', onMouseUp);
    window.addEventListener('click', onClick);
    window.addEventListener('wheel', onWheel);
    window.addEventListener('resize', onWindowResize);
    
    // 关闭面板按钮
    document.getElementById('close-panel').addEventListener('click', closeContentPanel);
}

// 鼠标移动事件
function onMouseMove(event) {
    mouse.x = (event.clientX / window.innerWidth) * 2 - 1;
    mouse.y = -(event.clientY / window.innerHeight) * 2 + 1;
    
    // 更新射线投射
    raycaster.setFromCamera(mouse, camera);
    const intersects = raycaster.intersectObjects(nodes);
    
    // 重置所有节点样式
    nodes.forEach(node => {
        if (node.userData.title) {
            node.material.emissiveIntensity = 0.3;
            node.scale.setScalar(1);
        }
    });
    
    // 高亮悬停的节点
    if (intersects.length > 0) {
        const hoveredNode = intersects[0].object;
        if (hoveredNode.userData.title) {
            hoveredNode.material.emissiveIntensity = 0.8;
            hoveredNode.scale.setScalar(1.3);
            
            // 显示工具提示
            showTooltip(hoveredNode.userData.title, event.clientX, event.clientY);
        }
    } else {
        hideTooltip();
    }
}

// 鼠标按下事件
function onMouseDown(event) {
    isMouseDown = true;
    document.body.style.cursor = 'grabbing';
}

// 鼠标释放事件
function onMouseUp(event) {
    isMouseDown = false;
    document.body.style.cursor = 'grab';
}

// 点击事件
function onClick(event) {
    if (isMouseDown) return;
    
    raycaster.setFromCamera(mouse, camera);
    const intersects = raycaster.intersectObjects(nodes);
    
    if (intersects.length > 0) {
        const clickedNode = intersects[0].object;
        if (clickedNode.userData.title) {
            handleNodeClick(clickedNode);
        }
    }
}

// 滚轮事件
function onWheel(event) {
    event.preventDefault();
    
    const zoomSpeed = 0.1;
    const direction = event.deltaY > 0 ? 1 : -1;
    
    // 限制缩放范围
    const newZ = camera.position.z + direction * zoomSpeed * 10;
    if (newZ > 10 && newZ < 200) {
        gsap.to(camera.position, {
            z: newZ,
            duration: 0.3,
            ease: "power2.out"
        });
    }
}

// 处理节点点击
function handleNodeClick(node) {
    const data = node.userData;
    
    if (data.template) {
        // 显示内容面板
        showContentPanel(data.title, data.template);
        
        // 相机动画到节点
        animateCameraToNode(node);
        
        // 显示子节点
        if (data.subNodes) {
            showSubNodes(data.title);
        }
    }
}

// 显示内容面板
function showContentPanel(title, templateId) {
    const panel = document.getElementById('content-panel');
    const panelTitle = document.getElementById('panel-title');
    const panelContent = document.getElementById('panel-content');
    
    // 获取模板内容
    const template = document.getElementById(templateId);
    if (template) {
        panelContent.innerHTML = template.innerHTML;
    }
    
    // 设置标题
    panelTitle.textContent = title;
    
    // 显示面板
    panel.classList.add('active');
    
    // 添加淡入动画
    gsap.fromTo(panel, 
        { opacity: 0, scale: 0.8 },
        { opacity: 1, scale: 1, duration: 0.5, ease: "back.out(1.7)" }
    );
}

// 关闭内容面板
function closeContentPanel() {
    const panel = document.getElementById('content-panel');
    
    gsap.to(panel, {
        opacity: 0,
        scale: 0.8,
        duration: 0.3,
        ease: "back.in(1.7)",
        onComplete: () => {
            panel.classList.remove('active');
        }
    });
    
    // 返回主视图
    animateCameraToMainView();
    hideSubNodes();
}

// 相机动画到节点
function animateCameraToNode(node) {
    const targetPosition = node.position.clone();
    targetPosition.z += 20; // 稍微后退一点
    
    gsap.to(camera.position, {
        x: targetPosition.x,
        y: targetPosition.y,
        z: targetPosition.z,
        duration: 1.5,
        ease: "power2.inOut"
    });
    
    // 让相机看向节点
    gsap.to(camera.lookAt, {
        x: node.position.x,
        y: node.position.y,
        z: node.position.z,
        duration: 1.5,
        ease: "power2.inOut",
        onUpdate: () => {
            camera.lookAt(node.position);
        }
    });
}

// 相机动画到主视图
function animateCameraToMainView() {
    gsap.to(camera.position, {
        x: 0,
        y: 0,
        z: 50,
        duration: 1.5,
        ease: "power2.inOut"
    });
    
    gsap.to(camera.rotation, {
        x: 0,
        y: 0,
        z: 0,
        duration: 1.5,
        ease: "power2.inOut"
    });
}

// 显示子节点
function showSubNodes(parentTitle) {
    nodes.forEach(node => {
        if (node.userData.title && node.userData.title !== parentTitle) {
            // 检查是否是子节点
            const isSubNode = Object.values(nodeData).some(data => 
                data.subNodes && data.subNodes.some(sub => sub.title === node.userData.title)
            );
            
            if (isSubNode) {
                node.visible = true;
                gsap.fromTo(node.scale,
                    { x: 0, y: 0, z: 0 },
                    { x: 1, y: 1, z: 1, duration: 0.5, ease: "back.out(1.7)" }
                );
            }
        }
    });
}

// 隐藏子节点
function hideSubNodes() {
    nodes.forEach(node => {
        if (node.userData.title) {
            const isSubNode = Object.values(nodeData).some(data => 
                data.subNodes && data.subNodes.some(sub => sub.title === node.userData.title)
            );
            
            if (isSubNode) {
                gsap.to(node.scale, {
                    x: 0,
                    y: 0,
                    z: 0,
                    duration: 0.3,
                    ease: "back.in(1.7)",
                    onComplete: () => {
                        node.visible = false;
                    }
                });
            }
        }
    });
}

// 显示工具提示
function showTooltip(text, x, y) {
    const tooltip = document.getElementById('tooltip');
    const tooltipContent = tooltip.querySelector('.tooltip-content');
    
    tooltipContent.textContent = text;
    tooltip.style.left = x + 10 + 'px';
    tooltip.style.top = y - 10 + 'px';
    tooltip.classList.add('visible');
}

// 隐藏工具提示
function hideTooltip() {
    const tooltip = document.getElementById('tooltip');
    tooltip.classList.remove('visible');
}

// 隐藏加载界面
function hideLoading() {
    const loading = document.getElementById('loading');
    gsap.to(loading, {
        opacity: 0,
        duration: 0.5,
        ease: "power2.out",
        onComplete: () => {
            loading.classList.add('hidden');
            isLoaded = true;
        }
    });
}

// 窗口大小调整
function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
}

// 渲染循环
function animate() {
    animationId = requestAnimationFrame(animate);
    
    // 自动旋转相机（仅在主视图）
    if (currentView === 'main' && !isMouseDown) {
        camera.position.x = Math.cos(Date.now() * 0.0005) * 50;
        camera.position.y = Math.sin(Date.now() * 0.0003) * 20;
        camera.lookAt(0, 0, 0);
    }
    
    // 更新粒子系统
    if (particleSystem) {
        particleSystem.rotation.y += 0.001;
    }
    
    // 渲染场景
    renderer.render(scene, camera);
}

// 页面加载完成后初始化
window.addEventListener('load', () => {
    // 检查Three.js和GSAP是否加载完成
    if (typeof THREE !== 'undefined' && typeof gsap !== 'undefined') {
        init();
    } else {
        console.error('Three.js或GSAP未正确加载');
    }
});

// 错误处理
window.addEventListener('error', (event) => {
    console.error('发生错误:', event.error);
});

// 页面卸载时清理资源
window.addEventListener('beforeunload', () => {
    if (animationId) {
        cancelAnimationFrame(animationId);
    }
    
    // 清理Three.js资源
    if (scene) {
        scene.clear();
    }
    
    if (renderer) {
        renderer.dispose();
    }
});

console.log('知识星云脚本已加载完成');

#include "shadermodel.h"

#include <QOpenGLShaderProgram>
#include <QOpenGLFunctions_4_0_Core>

ShaderModel::ShaderModel()
{
    m_roleNameMapping[ParameterName] = "displayRole";
    m_roleNameMapping[ParameterType] = "type";
    m_roleNameMapping[ParameterDatatype] = "datatype";
    m_roleNameMapping[ParameterValue] = "value";
    m_roleNameMapping[ParameterUniformLocation] = "location";
}

Qt3DRender::QShaderProgram ShaderModel::shaderProgram() const
{
    return m_shaderProgram;
}

void ShaderModel::sync(QStandardItem *si, QString uniformName)
{
    this->clear();
    // QOpenGLShaderProgram is not part of Qt3D.
    // It allows to parse the shader.
    QOpenGLShaderProgram shaderProgram;
    shaderProgram.create();
    if ( !shaderProgram.addShaderFromSourceFile( QOpenGLShader::Vertex, m_shaderProgram.vertexShaderCode() ) ) {
        qCritical() << QObject::tr( "Could not compile vertex shader. Log:" ) << shaderProgram.log();
    }
    if ( !shaderProgram.addShaderFromSourceFile( QOpenGLShader::Fragment, m_shaderProgram.fragmentShaderCode() ) ) {
        qCritical() << QObject::tr( "Could not compile fragment shader. Log:" ) << shaderProgram.log();
    }
    if(m_shaderProgram.geometryShaderCode().size() != 0) {
        if ( !shaderProgram.addShaderFromSourceFile( QOpenGLShader::Geometry, m_shaderProgram.geometryShaderCode() ) ) {
            qCritical() << QObject::tr( "Could not compile geometry shader. Log:" ) << shaderProgram.log();
        }
    }
    if(m_shaderProgram.tessellationControlShaderCode().size() != 0) {
        if ( !shaderProgram.addShaderFromSourceFile( QOpenGLShader::TessellationControl, m_shaderProgram.tessellationControlShaderCode() ) ) {
            qCritical() << QObject::tr( "Could not compile vertex tessellation control. Log:" ) << shaderProgram.log();
        }
    }
    if(m_shaderProgram.tessellationEvaluationShaderCode().size() != 0) {
        if ( !shaderProgram.addShaderFromSourceFile( QOpenGLShader::TessellationEvaluation, m_shaderProgram.tessellationEvaluationShaderCode() ) ) {
            qCritical() << QObject::tr( "Could not compile vertex tessellation evaluation. Log:" ) << shaderProgram.log();
        }
    }
    if(m_shaderProgram.computeShaderCode().size() != 0) {
        if ( !shaderProgram.addShaderFromSourceFile( QOpenGLShader::Compute, m_shaderProgram.computeShaderCode() ) ) {
            qCritical() << QObject::tr( "Could not compile compute shader. Log:" ) << shaderProgram.log();
        }
    }

    QOpenGLFunctions_4_0_Core *glFuncs = QOpenGLContext::currentContext()->versionFunctions<QOpenGLFunctions_4_0_Core>();
    if ( !glFuncs ) {
        qWarning() << "Unsupported Profile: QOpenGLFunctions_4_0_Core";
        return;
    }
    glFuncs->initializeOpenGLFunctions();

    shaderProgram.bind();

    QSet<QString> foundUniforms;
    GLint total = -1;
    glFuncs->glGetProgramiv( shaderProgram.programId(), GL_ACTIVE_UNIFORMS, &total );
    for(int i=0; i<total; ++i) {
        int name_len=-1, num=-1;
        GLenum type = GL_ZERO;
        char nameBuff[200];
        glFuncs->glGetActiveUniform( shaderProgram.programId(), GLuint(i), sizeof(nameBuff)-1,
            &name_len, &num, &type, nameBuff );
        nameBuff[name_len] = 0;
        GLuint location = glFuncs->glGetUniformLocation( shaderProgram.programId(), nameBuff );
        Q_ASSERT(location == i);
        QString name(nameBuff);
        if(m_blacklist.contains(name))
        {
            continue;
        }


        ShaderParameterInfo &theUniform = m_parameters.value(name); //TODO
        theUniform->setType( static_cast<ShaderParameterDatatype>(type) );
        theUniform->setUniformLocation( location );
        foundUniforms.insert( name );
    }


    shaderProgram.release();

    QStandardItem *csi = new QStandardItem();
    csi->setData(*iter, Qt::DisplayRole);
    csi->setData(childFullPath, Qt::ToolTipRole);
    if(si)
    {
        si->appendRow( csi );
    }
    else
    {
        this->appendRow( csi );
    }
}

QStringList ShaderModel::blacklist() const
{
    return m_blacklist;
}

void ShaderModel::setShaderProgram(Qt3DRender::QShaderProgram shaderProgram)
{
    if (m_shaderProgram == shaderProgram)
        return;

    m_shaderProgram = shaderProgram;
    sync(NULL, "");
    Q_EMIT shaderProgramChanged(m_shaderProgram);
}

void ShaderModel::setBlacklist(QStringList blacklist)
{
    if (m_blacklist == blacklist)
        return;

    m_blacklist = blacklist;
    Q_EMIT blacklistChanged(m_blacklist);
}
